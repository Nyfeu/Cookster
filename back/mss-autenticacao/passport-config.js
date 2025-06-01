const LocalStrategy = require('passport-local').Strategy
const GoogleStrategy = require('passport-google-oauth20').Strategy
const FacebookStrategy = require('passport-facebook').Strategy
const bcrypt = require('bcrypt')
const User = require('./models/User') 
// Array de usuários em memória (vou substituir por um BD depois)
//const users = []

function initialize(passport, getUserByEmail, getUserById) {
  
  const authenticateUser = async (email, password, done) => {
    const user = await getUserByEmail(email)
    if (!user) {
      return done(null, false, { message: 'Usuário não encontrado' })
    }

    try {
      if (await bcrypt.compare(password, user.password)) {
        return done(null, user)
      } else {
        return done(null, false, { message: 'Senha incorreta' })
      }
    } catch (e) {
      return done(e)
    }
  }

  passport.use(new LocalStrategy({ usernameField: 'email' }, authenticateUser))

  passport.use(new GoogleStrategy({
  clientID: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  callbackURL: "/auth/google/callback"
}, async (accessToken, refreshToken, profile, done) => {
  try {
    let user = await User.findOne({ email: profile.emails[0].value })

    if (!user) {
      user = new User({
        id: profile.id,
        name: profile.displayName,
        email: profile.emails[0].value,
        password: '', // como não há senha vinda do Google
      });

      await user.save()
    }

    return done(null, user)
  } catch (err) {
    return done(err, null)
  }
}));

    passport.use(new FacebookStrategy({
    clientID: process.env.FACEBOOK_CLIENT_ID,
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET,
    callbackURL: '/auth/facebook/callback',
    profileFields: ['id', 'displayName', 'emails']
  }, async (accessToken, refreshToken, profile, done) => {
    try {
      const email = profile.emails?.[0]?.value;

      let user = await User.findOne({ email });

      if (!user) {
        user = new User({
          id: profile.id,
          name: profile.displayName,
          email: email || '', // Facebook pode não retornar e-mail
          password: '', // Usuários de OAuth não têm senha
        });

        await user.save();
      }

      return done(null, user);
    } catch (err) {
      return done(err, null);
    }
  }));


}

module.exports = initialize
