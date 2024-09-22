import Vapor
import FluentMySQLDriver

class UserController: RouteCollection, @unchecked Sendable {
    func boot(routes: RoutesBuilder) throws {
        
    }

    @Sendable
    func registerUser(_ req: Request) async throws -> Response {
        let user = try req.content.decode(User.self)
        
        try User.validate(content: req)

        user.password = try await req.password.async.hash(user.password)

        try await user.save(on: req.db)

        return Response(status: .created)
    }

    @Sendable
    func getAllUsers(_ req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    @Sendable
    func updateUser(_ req: Request) async throws -> Response {
        let newUserValue = try req.content.decode(User.self)
        let oldUser = try await getUserId(id: newUserValue.id, db: req.db)

        try await getUpdatedUserValue(oldUserValue: oldUser, newUserValue: newUserValue, req: req).update(on: req.db)

        return Response(status: .ok)
    }

    func getUserId(id: UUID?, db: Database) async throws -> User {
        guard let user = try await User.find(id, on: db) else {
            throw Abort(.notFound)
        }

        return user
    }

    func getUpdatedUserValue(oldUserValue: User, newUserValue: User, req: Request) async throws -> User {
        if !newUserValue.name.isEmpty {
            oldUserValue.name = newUserValue.name
        }

        if !newUserValue.email.isEmpty {
            oldUserValue.email = newUserValue.email
        }

        if !newUserValue.password.isEmpty {
            oldUserValue.password = try await req.password.async.hash(newUserValue.password)
        }

        return oldUserValue
    }
}