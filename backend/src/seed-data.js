const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.TABLE_NAME || 'HelloSaaSGreetings';

const greetings = [
  { languageCode: 'en', languageName: 'English', greeting: 'Hello SaaS!' },
  { languageCode: 'es', languageName: 'Spanish', greeting: '¡Hola SaaS!' },
  { languageCode: 'fr', languageName: 'French', greeting: 'Bonjour SaaS!' },
  { languageCode: 'de', languageName: 'German', greeting: 'Hallo SaaS!' },
  { languageCode: 'ja', languageName: 'Japanese', greeting: 'こんにちは SaaS!' },
  { languageCode: 'zh', languageName: 'Chinese', greeting: '你好 SaaS!' }
];

async function seedData() {
  console.log(`Seeding data to table: ${TABLE_NAME}`);

  for (const greeting of greetings) {
    try {
      const command = new PutCommand({
        TableName: TABLE_NAME,
        Item: greeting
      });

      await docClient.send(command);
      console.log(`✓ Added ${greeting.languageName} greeting`);
    } catch (error) {
      console.error(`✗ Failed to add ${greeting.languageName}:`, error.message);
    }
  }

  console.log('Data seeding complete!');
}

seedData().catch(console.error);
