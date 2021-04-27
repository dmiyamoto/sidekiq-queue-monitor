# Overview

<img src="https://user-images.githubusercontent.com/1298519/116212665-0535da80-a780-11eb-8632-7290ea61bb10.png" width=500 />

※ If you wanna send sidekiq queue status to your slack workspace, you can use [alert-slack-notifier](https://github.com/dmiyamoto/alert-slack-notifier).

# slack notice example

<img src="https://user-images.githubusercontent.com/1298519/116217851-f00f7a80-a784-11eb-87c6-df267d369967.png" width=200>

# deploy

### Manual

1. `bundle install --path vendor/bundle`
1. `zip -r function.zip lambda_function.rb vendor`

# Environment Variable

- `REDIS_URL`
  - Required
  - Set Elasticashe(redis mode) endpoint
  - i.e. redis://xxxxxxxxxxxxxxxxxxxx.amazonaws.com:6379
- `QUEUE_TYPES`
  - Required
  - Set Array with sidekiq queue categories.
  - i.e. ["default", "event", "low"]
- `SIZE_THRESHOLD`
  - Required
  - i.e. 30
- `LATENCY_THRESHOLD`
  - Required
  - i.e. 30
- `LAMBDA_NAME_FOR_SLACK_NOTIFY`
  - Required
  - Set Lambda Name for slack notice
- `VPC_ENDPOINT`
  - Required
  - Set VPC endpoint for Lambda
  - i.e. https://vpce-xxxxxxxxxxxxxxx.lambda.ap-northeast-1.vpce.amazonaws.com

# Lambda Settings

- Trigger
  - CloudWatch Events
- Timeout
  - 180 [s]
