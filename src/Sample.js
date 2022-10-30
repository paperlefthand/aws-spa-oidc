import './Sample.css';
import { Component } from 'react';
import { Amplify, Auth, API } from 'aws-amplify';
import jwtDecode from 'jwt-decode';

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

class Sample extends Component {
  constructor(props) {
    super(props);
    this.state = {
      authState: null,
      email: null
    };
  }

  componentDidMount = async () => {
    const awsCred = await Auth.currentCredentials();
    if (!awsCred.authenticated) {
      console.log('未認証');
      this.setState({ authState: 'signOut', email: null });
      return;
    }
    console.log('認証済');
    const session = await Auth.currentSession();
    const decodedIdToken = jwtDecode(session.idToken.jwtToken);
    this.setState({ authState: 'signedIn', email: decodedIdToken.email });
  }

  signOut = async () => {
    await Auth.signOut();
    console.log('signOut');
    this.setState({ authState: 'signOut', email: null });
  };

  execApi = async () => {
    const path = '/sample'
    const resBody = await API.get('API_ENDPOINT', path);
    console.log('resBody:', resBody);
  };

  render() {
    const { authState, email } = this.state;
    return (
      <div>
        <div className="signin">
          {authState === 'signOut' && <a className="App-link" href={HOSTED_UI_URL}>Sign-In with UserPool Hosted-UI</a>}
          {authState === 'signedIn' && <AuthedContents email={email} signOut={this.signOut} execApi={this.execApi} />}
        </div>
      </div>
    );
  }
}

const AuthedContents = ({email, signOut, execApi}) => {
  return (
    <div className="sessionInfo">
      <h3>-- Authenticated! --</h3>
      <p>email: {email}</p>
      <p className="actionButton"><button onClick={signOut}>サインアウト</button></p>
      <p className="actionButton"><button onClick={execApi}>サンプルAPI Call</button></p>
    </div>
  );
};

export default Sample;
