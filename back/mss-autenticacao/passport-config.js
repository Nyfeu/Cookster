const LocalStrategy = require('passport-local').Strategy
const GoogleStrategy = require('passport-google-oauth20').Strategy
const FacebookStrategy = require('passport-facebook').Strategy
const bcrypt = require('bcrypt')

// Array de usuários em memória (vou substituir por um BD depois)
const users = []

function initialize(passport, getUserByEmail, getUserById) {
  
  const authenticateUser = async (email, password, done) => {
    const user = getUserByEmail(email)
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
  }, (accessToken, refreshToken, profile, done) => {
    let user = users.find(user => user.email === profile.emails[0].value)

    if (!user) {
      user = {
        id: profile.id,
        name: profile.displayName,
        email: profile.emails[0].value,
        provider: 'google'
      }
      users.push(user)
    }

    return done(null, user)
  }))

  passport.use(new FacebookStrategy({
    clientID: process.env.FACEBOOK_CLIENT_ID,
    clientSecret: process.env.FACEBOOK_CLIENT_SECRET,
    callbackURL: '/auth/facebook/callback',
    profileFields: ['id', 'displayName', 'emails']
  }, (accessToken, refreshToken, profile, done) => {
    let user = users.find(u => u.id === profile.id)

    if (!user) {
      user = {
        id: profile.id,
        name: profile.displayName,
        email: profile.emails?.[0]?.value || null,
        provider: 'facebook'
      }
      users.push(user)
    }

    return done(null, user)
  }))

}

module.exports = initialize
