import './App.css';
import React, { useState, useEffect } from 'react';
import { Amplify, Auth, API } from 'aws-amplify';
import { jwtDecode } from 'jwt-decode';

const REGION = process.env.REACT_APP_Region;
const USERPOOL_CLIENT_ID = process.env.REACT_APP_UserPoolClientId;
const USERPOOL_DOMAIN = process.env.REACT_APP_UserPoolDomain;
const SINGIN_URL = process.env.REACT_APP_SignInUrl;
const SINGOUT_URL = process.env.REACT_APP_SignOutUrl;
const OIDC_SCOPE = process.env.REACT_APP_OIDC_Scope;

const ENDPOINT_DOMAIN = `${USERPOOL_DOMAIN}.auth.${REGION}.amazoncognito.com`;
const HOSTED_UI_URL = `https://${ENDPOINT_DOMAIN}/login?client_id=${USERPOOL_CLIENT_ID}&response_type=code&scope=${OIDC_SCOPE}&redirect_uri=${SINGIN_URL}`;

Amplify.configure({
  Auth: {
    region: REGION,
    userPoolId: process.env.REACT_APP_UserPoolId,
    userPoolWebClientId: USERPOOL_CLIENT_ID,
    // identityPoolId: process.env.REACT_APP_IdentityPoolId,
    oauth: {
      domain: ENDPOINT_DOMAIN,
      scope: OIDC_SCOPE.split('+'),
      redirectSignIn: SINGIN_URL,
      redirectSignOut: SINGOUT_URL,
      responseType: 'code'
    }
  },
  API: {
    endpoints: [
      {
        name: 'API_ENDPOINT',
        endpoint: process.env.REACT_APP_HttpApiEndpoint,
        region: REGION
      }
    ]
  }
});

const App = () => {

  const [signedIn, setSignedIn] = useState(false)
  const [email, setEmail] = useState(null)
  const [jwtToken, setJwtToken] = useState(null)
  const [personalData, setPersonalData] = useState(null)

  useEffect(() => {
    (async () => {
      // const awsCred = await Auth.currentCredentials();
      const session = await Auth.currentSession();
      if (session.isValid()) {
        console.log('認証済');
        const decodedIdToken = jwtDecode(session.idToken.jwtToken);
        const user = await Auth.currentAuthenticatedUser()
        setSignedIn(true);
        setEmail(decodedIdToken.email);
        setJwtToken(session.idToken.jwtToken);
      } else {
        console.log('未認証');
        setSignedIn(false);
        setEmail(null);
        setJwtToken(null);
      }
    })()
  }, [setSignedIn, setEmail, setJwtToken]);

  const signIn = async () => {
    await Auth.federatedSignIn({ provider: 'google' });
    console.log('signIn');
    setSignedIn(true);
  };

  const signOut = async () => {
    await Auth.signOut();
    console.log('signOut');
    setSignedIn(false);
    setEmail(null);
    setJwtToken(null);
  };

  const execApi = async () => {
    const path = process.env.REACT_APP_HttpApiPath
    const resBody = await API.get('API_ENDPOINT', path,
      {
        headers: {
          Authorization: jwtToken
        },
      }
    );
    console.log('resBody:', resBody);
    setPersonalData(resBody["message"])
  };

  return (
    <div>
      <div className="signin">
        {!signedIn && <button onClick={signIn}>login</button>}
        {signedIn && <AuthedContents email={email} signOut={signOut} execApi={execApi} />}
      </div>
      <p>{personalData}</p>
    </div>
  );
}

const AuthedContents = ({ email, signOut, execApi }) => {
  return (
    <div className="sessionInfo">
      <h3>-- Authenticated! --</h3>
      <p>your email: {email}</p>
      <p className="actionButton"><button onClick={signOut}>サインアウト</button></p>
      <p className="actionButton"><button onClick={execApi}>サンプルAPI Call</button></p>
    </div>
  );
};

export default App;
