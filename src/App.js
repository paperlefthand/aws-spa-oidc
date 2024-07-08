import './App.css';
import React, { useState, useEffect } from 'react';
import { Amplify, Auth, API } from 'aws-amplify';
import { jwtDecode } from 'jwt-decode';

const REGION = process.env.REACT_APP_Region;
const USERPOOL_CLIENT_ID = process.env.REACT_APP_UserPoolClientId;
const USERPOOL_DOMAIN = process.env.REACT_APP_UserPoolDomain;
const SINGIN_URL = process.env.REACT_APP_SignInUrl;
const OIDC_SCOPE = process.env.REACT_APP_OIDC_Scope;

const ENDPOINT_DOMAIN = `${USERPOOL_DOMAIN}.auth.${REGION}.amazoncognito.com`;
const HOSTED_UI_URL = `https://${ENDPOINT_DOMAIN}/login?client_id=${USERPOOL_CLIENT_ID}&response_type=code&scope=${OIDC_SCOPE}&redirect_uri=${SINGIN_URL}`;

Amplify.configure({
  Auth: {
    region: REGION,
    userPoolId: process.env.REACT_APP_UserPoolId,
    userPoolWebClientId: USERPOOL_CLIENT_ID,
    identityPoolId: process.env.REACT_APP_IdentityPoolId,
    oauth: {
      domain: ENDPOINT_DOMAIN,
      scope: OIDC_SCOPE.split('+'),
      redirectSignIn: SINGIN_URL,
      redirectSignOut: SINGIN_URL,
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

  const [authState, setAuthState] = useState('signOut')
  const [email, setEmail] = useState(null)
  const [jwtToken, setJwtToken] = useState(null)
  const [personalData, setPersonalData] = useState(null)

  useEffect(() => {
    (async () => {
      const awsCred = await Auth.currentCredentials();
      if (!awsCred.authenticated) {
        console.log('未認証');
        setAuthState('signOut');
        setEmail(null);
        setJwtToken(null);
        return;
      }
      console.log('認証済');
      const session = await Auth.currentSession();
      const decodedIdToken = jwtDecode(session.idToken.jwtToken);
      setAuthState('signedIn');
      setEmail(decodedIdToken.email);
      setJwtToken(session.idToken.jwtToken);
    })()
  }, [setAuthState, setEmail, setJwtToken]);

  const signOut = async () => {
    await Auth.signOut();
    console.log('signOut');
    setAuthState('signOut');
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
        {authState === 'signOut' && <a className="App-link" href={HOSTED_UI_URL}>Sign-In with UserPool Hosted-UI</a>}
        {authState === 'signedIn' && <AuthedContents email={email} signOut={signOut} execApi={execApi} />}
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
