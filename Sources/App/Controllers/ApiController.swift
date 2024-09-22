import Vapor

class ApiController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        
        applyUserController(api)
    }

    func applyUserController(_ api: RoutesBuilder) {
        let users = api.grouped("users")
        let userController = UserController()

        users.post("register", use: userController.registerUser)
        users.post("update", use: userController.updateUser)
        users.get("all", use: userController.getAllUsers)
    }
}