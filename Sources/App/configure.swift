import Fluent
import FluentPostgresDriver
import Vapor

extension Application {
  static var databaseUrl: URL? {
    
    let dbUrlKey: String
    
    #if DEBUG
    dbUrlKey = "DB_URL"
    #else
    dbUrlKey = "DATABASE_URL"
    #endif
    
    guard let dbUrlString = Environment.get(dbUrlKey) else { return nil }
    return URL(string: dbUrlString)
  }
}

// configures your application
public func configure(_ app: Application) throws {
  
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  
  if let databaseUrl = Application.databaseUrl {
    try app.databases.use(.postgres(url: databaseUrl), as: .psql)
  }
  
  app.migrations.add(CreateChat())
  app.migrations.add(CreateMessage())
  app.migrations.add(CreateUser())
  app.migrations.add(CreateChatUser())
  app.migrations.add(CreateToken())
  
  // register routes
  try routes(app)
  
  // register for apns
  let config: APNSwiftConfiguration
  
  #if DEBUG
  config = APNSwiftConfiguration(
    authenticationMethod: .jwt(
      key: try .private(filePath: "Sources/App/Secrets/AuthKey.p8"),
      keyIdentifier: "AuthKey_id",
      teamIdentifier: "team_id"),
    topic: "com.example.chat",
    environment: .sandbox)
  #else
  config = APNSwiftConfiguration(
    authenticationMethod: .jwt(
      key: try .private(filePath: "Sources/App/Secrets/AuthKey.p8"),
      keyIdentifier: "AuthKey_id",
      teamIdentifier: "Team_id"),
    topic: "com.example.chat",
    environment: .production)
  #endif
  
  app.apns.configuration = config
}
