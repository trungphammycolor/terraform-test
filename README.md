<br />

## NextAuth & AWS Cognito env setup
```
NEXTAUTH_URL=
NEXTAUTH_SECRET=
# NEXTAUTH_SECRET use uuid4 or your secret key
# uuid online create: https://www.uuidgenerator.net/version4
# nextauth docs: (https://next-auth.js.org/configuration/options#secret)

NEXT_PUBLIC_AWS_COGNITO_CLIENT_ID=
NEXT_PUBLIC_AWS_COGNITO_USER_POOL_ID=
NEXT_PUBLIC_AWS_COGNITO_DOMAIN_URL=
NEXT_PUBLIC_AWS_COGNITO_IDP_URL=
NEXT_PUBLIC_AWS_COGNITO_REGION=
```
<br/>

### Please register your callback URL in AWS Cognito & Google Cloud Platform
```
Email callback url: {your domain}/sign-in
```
<br/>
