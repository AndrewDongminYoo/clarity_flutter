// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

internal class ClarityGaidHostApiImpl: ClarityGaidHostApi {

    func getGaid() throws -> String? { GaidBridge.getGaid() }
}
