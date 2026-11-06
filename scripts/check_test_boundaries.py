#!/usr/bin/env python3
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / '.mutineer' / 'boundary-check.json'
REPORT = ROOT / '.mutineer' / 'boundary-report.json'
PREFIXES = ('app/models/', 'app/contexts/', 'spec/models/', 'spec/contexts/')
SHARED = ('spec/spec_helper.rb', 'Gemfile', 'Gemfile.lock', '.mutineer.yml', 'bin/mutineer',
          '.rspec', '.devcontainer/Dockerfile', 'scripts/check_test_boundaries.py')


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT).decode().strip()


def changed_paths(base):
    merge_base = git('merge-base', base, 'HEAD')
    changed = subprocess.check_output(
        ['git', 'diff', '--name-only', '-z', merge_base], cwd=ROOT
    )
    untracked = subprocess.check_output(
        ['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=ROOT
    )
    return set(os.fsdecode(p) for p in (changed + untracked).split(b'\0') if p)


def relevant(path):
    return (path.endswith('.rb') and path.startswith(PREFIXES + ('spec/support/', 'spec/fabricators/'))) or path.startswith('config/') or path in SHARED


def fingerprint():
    digest = hashlib.sha256()
    paths = set(SHARED)
    for folder in ('app/models', 'app/contexts', 'spec', 'config'):
        paths.update(str(p.relative_to(ROOT)) for p in (ROOT / folder).rglob('*.rb'))
    paths.update(str(p.relative_to(ROOT)) for p in (ROOT / 'config').rglob('*.yml'))
    for name in sorted(paths):
        path = ROOT / name
        digest.update(name.encode() + b'\0')
        digest.update(path.read_bytes() if path.is_file() else b'<missing>')
        digest.update(b'\0')
    return digest.hexdigest()


def verdict(report, returncode):
    if not isinstance(report, dict) or not isinstance(report.get('summary'), dict):
        return 'Mutineer のJSONレポートが不正です。'
    summary = report.get('summary', {})
    if returncode != 0:
        return 'Mutineer が正常終了していません。'
    if not isinstance(summary.get('score'), (int, float)) or summary.get('attempted', 0) <= 0:
        return '採点できる変異がありません。対象や設定を確認してください。'
    for field in ('survived', 'no_coverage', 'uncapturable', 'unplaceable', 'ran_at_load', 'errored', 'timeout', 'no_verdict', 'ignored'):
        if summary.get(field, 0) != 0:
            return f'{field} が {summary[field]} 件あります。JSON の明細を確認してください。'
    if summary.get('killed') != summary.get('attempted'):
        return '実行した変異のすべてについて検出を確認できていません。'
    return None


def load_state():
    try:
        state = json.loads(STATE.read_text())
        return state if isinstance(state, dict) else {}
    except (OSError, ValueError):
        return {}


def checked(current):
    state = load_state()
    if state.get('fingerprint') != current or state.get('result') != 'passed':
        return False
    try:
        return hashlib.sha256(REPORT.read_bytes()).hexdigest() == state.get('report_sha256') and verdict(json.loads(REPORT.read_text()), 0) is None
    except (OSError, ValueError):
        return False


def run(local=False):
    STATE.parent.mkdir(exist_ok=True)
    before = fingerprint()
    STATE.unlink(missing_ok=True)
    REPORT.unlink(missing_ok=True)
    command = ['bin/mutineer', 'run', 'app/models', 'app/contexts', '--no-since',
               '--no-fail-fast', '--threshold', '100', '--format', 'json',
               '--output', str(REPORT.relative_to(ROOT))]
    # Explicit specs keep sources without a conventionally paired spec in scope.
    for folder in ('spec/models', 'spec/contexts'):
        for spec in sorted((ROOT / folder).rglob('*_spec.rb')):
            command.extend(['--test', str(spec.relative_to(ROOT))])
    if not local and not Path('/.dockerenv').exists():
        command = ['bin/dc', 'exec', '--workspace-folder', '.', *command]
    result = subprocess.run(command, cwd=ROOT)
    if before != fingerprint():
        raise RuntimeError('実行中に対象ファイルが変更されました。再実行してください。')
    report = json.loads(REPORT.read_text()) if REPORT.exists() else {}
    error = verdict(report, result.returncode)
    if error:
        print(error, file=sys.stderr)
        return 1
    STATE.write_text(json.dumps({'fingerprint': before, 'result': 'passed',
        'report_sha256': hashlib.sha256(REPORT.read_bytes()).hexdigest()}))
    print('境界値の自動変異チェックが完了しました。定数・SQL等の境界は別途確認してください。')
    return 0


def hook(payload, base):
    if not any(relevant(p) for p in changed_paths(base)) or checked(fingerprint()):
        return {}
    reason = ('境界値の確認が未実行、失敗、または変更後に未更新です。'
              'python3 scripts/check_test_boundaries.py --run を実行し、'
              '.mutineer/boundary-report.json の見逃し・未実行・エラーを確認してください。'
              '妥当なテストを追加して再実行し、定数・SQLなど自動解析対象外の境界も確認してください。'
              'ignore や仕様変更で判定を通さず、解決できない場合は理由を報告してください。')
    if payload.get('stop_hook_active'):
        return {'systemMessage': '境界値チェックは未完了です。自動続行を繰り返さず、未解決事項を利用者へ報告してください。'}
    return {'decision': 'block', 'reason': reason}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--run', action='store_true')
    parser.add_argument('--local', action='store_true', help='Use the prepared Ruby environment (CI or container).')
    parser.add_argument('--base', default='origin/main')
    args = parser.parse_args()
    payload = {}
    try:
        if args.run:
            STATE.parent.mkdir(exist_ok=True)
            with (STATE.parent / 'boundary-check.lock').open('w') as lock:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                return run(args.local)
        payload = json.load(sys.stdin)
        output = hook(payload, args.base)
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        if args.run:
            print(str(error), file=sys.stderr)
            return 1
        message = f'境界値チェックのフックが失敗しました: {error}。設定や基準ブランチを確認してください。'
        output = {'systemMessage': message} if payload.get('stop_hook_active') else {'decision': 'block', 'reason': message}
    print(json.dumps(output, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    sys.exit(main())
