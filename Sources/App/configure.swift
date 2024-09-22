import Vapor
import FluentMySQLDriver

public func configure(_ app: Application) async throws {
  try appConfigurePools(app: app)
  try appUseMigrations(app: app)
  try appUseDatabases(app: app)

  try routes(app)
}

func appUseDatabases(app: Application) throws {
  let configuration = getConfiguration()

  app.databases.use(.mysql(configuration: configuration), as: .mysql)
}

func appUseMigrations(app: Application) throws {
  app.migrations.add(CreateUsersTableMigration())
}

func appConfigurePools(app: Application) throws {
  let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
  let configuration = getConfiguration()

  defer { try! eventLoopGroup.syncShutdownGracefully() }

  let pools = EventLoopGroupConnectionPool(
    source: MySQLConnectionSource(configuration: configuration),
    on: eventLoopGroup
  )

  do { pools.shutdown() }
}

func getConfiguration() -> MySQLConfiguration {
    var TLSConfiguration = TLSConfiguration.clientDefault

    TLSConfiguration.certificateVerification = .none

    return MySQLConfiguration(
    hostname: Environment.get("MYSQL_HOSTNAME") ?? "",
    port: Environment.get("MYSQL_PORT").flatMap(Int.init) ?? 0,
    username: Environment.get("MYSQL_USERNAME") ?? "",
    password: Environment.get("MYSQL_PASSWORD") ?? "",
    database: Environment.get("MYSQL_DATABASE") ?? "",
    tlsConfiguration: TLSConfiguration)
}