const passport = require('passport');
const FacebookStrategy = require('passport-facebook').Strategy;

const FACEBOOK_APP_ID = process.env.FACEBOOK_APP_ID;
const FACEBOOK_APP_SECRET = process.env.FACEBOOK_APP_SECRET;

function initializeFacebookStrategy() {
  passport.use(new FacebookStrategy({
    clientID: FACEBOOK_APP_ID,
    clientSecret: FACEBOOK_APP_SECRET,
    callbackURL: "http://localhost:3000/auth/facebook/callback",
    profileFields: ['id', 'displayName', 'emails'], // Pede e-mail também
    passReqToCallback: true,
  }, (request, accessToken, refreshToken, profile, done) => {
    return done(null, {
        id: profile.id,
        name: profile.displayName,
        email: profile.emails?.[0]?.value || '',
    });
  }));
}

module.exports = initializeFacebookStrategy;
