import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('checks', Path(__file__).parents[1] / 'check_test_boundaries.py')
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


class BoundaryCheckTest(unittest.TestCase):
    def summary(self, **updates):
        values = dict(score=100, attempted=2, killed=2)
        values.update(updates)
        return {'summary': values}

    def test_unscored_and_partially_executed_reports_do_not_pass(self):
        for values in ({'score': None}, {'attempted': 0}, {'survived': 1},
                       {'no_coverage': 1}, {'errored': 1}, {'ignored': 1}, {'killed': 1}):
            with self.subTest(values=values):
                self.assertIsNotNone(checks.verdict(self.summary(**values), 0))
        self.assertIsNone(checks.verdict(self.summary(), 0))
        self.assertIsNotNone(checks.verdict(self.summary(), 1))
        self.assertIsNotNone(checks.verdict([], 0))
        self.assertIsNotNone(checks.verdict({'summary': []}, 0))

    def test_spec_only_change_requests_check_and_continuation_does_not_loop(self):
        with patch.object(checks, 'changed_paths', return_value={'spec/models/post_spec.rb'}), \
             patch.object(checks, 'fingerprint', return_value='new'), \
             patch.object(checks, 'checked', return_value=False):
            self.assertEqual(checks.hook({}, 'main')['decision'], 'block')
            response = checks.hook({'stop_hook_active': True}, 'main')
            self.assertNotIn('decision', response)
            self.assertIn('未完了', response['systemMessage'])

    def test_checked_content_can_stop_but_changed_content_cannot(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / 'state.json'
            report = Path(directory) / 'report.json'
            report.write_text(json.dumps(self.summary()))
            state.write_text(json.dumps(dict(fingerprint='old', result='passed',
                report_sha256=checks.hashlib.sha256(report.read_bytes()).hexdigest())))
            with patch.object(checks, 'STATE', state), patch.object(checks, 'REPORT', report):
                self.assertTrue(checks.checked('old'))
                self.assertFalse(checks.checked('new'))
                report.write_text(json.dumps(self.summary(survived=1)))
                self.assertFalse(checks.checked('old'))

    def test_deleted_and_new_specs_change_fingerprint(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(checks, 'ROOT', Path(directory)):
            path = Path(directory) / 'spec/models/new_spec.rb'
            path.parent.mkdir(parents=True)
            before = checks.fingerprint()
            path.write_text('expect(value).to eq 10')
            self.assertNotEqual(checks.fingerprint(), before)
            path.unlink()
            self.assertEqual(checks.fingerprint(), before)

    def test_documentation_only_change_does_not_require_run(self):
        with patch.object(checks, 'changed_paths', return_value={'README.md'}):
            self.assertEqual(checks.hook({}, 'main'), {})


if __name__ == '__main__':
    unittest.main()
