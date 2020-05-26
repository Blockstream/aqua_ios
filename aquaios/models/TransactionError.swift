enum TransactionError: Error {
    case invalidAddress(_ localizedDescription: String)
    case invalidAmount(_ localizedDescription: String)
    case generic(_ localizedDescription: String)
}
