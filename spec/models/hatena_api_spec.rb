# -*- coding: utf-8 -*-
describe HatenaApi do
  describe '#add_status?' do
    context 'コンストラクタの引数が {status: "add"} のとき' do
      let(:api) { HatenaApi.new(status: 'add') }

      it 'true を返すこと' do
        expect(api.add_status?).to be_true
      end
    end

    context 'コンストラクタの引数が {status: "delete"} のとき' do
      let(:api) { HatenaApi.new(status: 'delete') }

      it 'false を返すこと' do
        expect(api.add_status?).to be_false
      end
    end

    context 'コンストラクタの引数が {status: nil} のとき' do
      let(:api) { HatenaApi.new(status: nil) }

      it 'false を返すこと' do
        expect(api.add_status?).to be_false
      end
    end
  end

  describe '#valid_key?' do
    context 'コンストラクタの引数が {key: "hoge"} のとき' do
      let(:api) { HatenaApi.new(key: 'hoge') }

      context 'かつ #hatena_key が "hoge" の User が存在するとき' do
        before do
          User.skip_callback(:create, :before, :set_hatena_key)
          Fabricate(:user, hatena_key: 'hoge')
          User.set_callback(:create, :before, :set_hatena_key)
        end

        it 'true を返すこと' do
          expect(api.valid_key?).to be_true
        end
      end

      context 'かつ #hatena_key が "hoge" の User が存在しないとき' do
        it 'false を返すこと' do
          expect(api.valid_key?).to be_false
        end
      end
    end
  end

  describe '#body' do
    context 'コンストラクタの引数が {title: "タイトル", comment: "コメント本文", url: "http://willnet.in"} のとき' do
      let(:api) do
        HatenaApi.new(
          title: 'タイトル',
          comment: 'コメント本文',
          url: 'http://willnet.in'
        )
      end

      it '"[タイトル](http://willnet.in)\nコメント本文" が返ること' do
        expect(api.body).to eq "[タイトル](http://willnet.in)\nコメント本文"
      end
    end
  end
end
