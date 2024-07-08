# OIDC認証を行うSPAのサンプルコード

## デバッグ

```sh
# .envでREACT_APP_SignInUrl=http://localhost:3000
npm run start 
```

## UIテスト

```sh
npx playwright test --ui
```

## deploy

```sh
cd terraform
terraform apply
```

## webページ更新

```sh
# .envでREACT_APP_SignInUrlをcloudfrontのURLへ
npm run build
aws s3 sync build s3://spa-oidc --delete --profile dev
```

## 参考

- <https://qiita.com/Keiichi_Kinoshita/items/19a3c1db8b1c5504f184>
