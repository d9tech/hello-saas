const cdk = require('aws-cdk-lib');
const dynamodb = require('aws-cdk-lib/aws-dynamodb');
const lambda = require('aws-cdk-lib/aws-lambda');
const apigateway = require('aws-cdk-lib/aws-apigateway');
const { Construct } = require('constructs');

class HelloSaasStack extends cdk.Stack {
  constructor(scope, id, props) {
    super(scope, id, props);

    const table = new dynamodb.Table(this, 'GreetingsTable', {
      tableName: 'HelloSaaSGreetings',
      partitionKey: { name: 'languageCode', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.DESTROY
    });

    const greetingFunction = new lambda.Function(this, 'GreetingFunction', {
      functionName: 'HelloSaaSGreetingFunction',
      runtime: lambda.Runtime.NODEJS_18_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('../backend/src'),
      environment: {
        TABLE_NAME: table.tableName
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 256
    });

    table.grantReadData(greetingFunction);

    const api = new apigateway.RestApi(this, 'GreetingApi', {
      restApiName: 'Hello SaaS API',
      description: 'API for Hello SaaS multilingual greetings',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
        allowHeaders: ['Content-Type', 'X-Amz-Date', 'Authorization', 'X-Api-Key']
      }
    });

    const greetingResource = api.root.addResource('api').addResource('greeting');
    greetingResource.addMethod('GET', new apigateway.LambdaIntegration(greetingFunction));

    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
      description: 'API Gateway URL',
      exportName: 'HelloSaaSApiUrl'
    });

    new cdk.CfnOutput(this, 'TableName', {
      value: table.tableName,
      description: 'DynamoDB Table Name'
    });
  }
}

const app = new cdk.App();
new HelloSaasStack(app, 'HelloSaasStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION
  }
});
