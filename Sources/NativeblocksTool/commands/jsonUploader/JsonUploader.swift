import Foundation
import _NativeblocksCompilerCommon

public class JsonUploader {
    let endpoint: String
    let authToken: String
    let organizationId: String

    public init(
        endpoint: String,
        authToken: String,
        organizationId: String
    ) {
        self.endpoint = endpoint
        self.authToken = authToken
        self.organizationId = organizationId

        NetworkExecutor.initialize(endpoint: endpoint, apiKey: authToken)
    }

    public func upload(
        blocks: [NativeBlock],
        actions: [NativeAction]
    ) throws {
        for block in blocks {
            print("Sync Block:\(block.keyType) start...")
            var input = block
            input.organizationId = organizationId
            let integrationId = try JsonUploader.syncIntegration(input: input)

            let datas = block.meta.compactMap { $0 as? DataNativeMeta }
            let events = block.meta.compactMap { $0 as? EventNativeMeta }
            let properties = block.meta.compactMap { $0 as? PropertyNativeMeta }
            let slots = block.meta.compactMap { $0 as? SlotNativeMeta }

            print("Sync Data start")
            try JsonUploader.syncIntegrationData(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: datas
            )
            print("Sync Data done")

            print("Sync Properties start")
            try JsonUploader.syncIntegrationProperties(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: properties
            )
            print("Sync Properties done")

            print("Sync Events start")
            try JsonUploader.syncIntegrationEvents(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: events
            )
            print("Sync Events done")

            print("Sync Slots start")
            try JsonUploader.syncIntegrationSlots(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: slots
            )
            print("Sync Slots done")

            print("Sync Block:\(block.keyType) done")
        }

        for action in actions {
            print("Sync Action:\(action.keyType) start...")
            var input = action
            input.organizationId = organizationId
            let integrationId = try JsonUploader.syncIntegration(input: input)

            let datas = action.meta.compactMap { $0 as? DataNativeMeta }
            let events = action.meta.compactMap { $0 as? EventNativeMeta }
            let properties = action.meta.compactMap { $0 as? PropertyNativeMeta }

            print("Sync Data start")
            try JsonUploader.syncIntegrationData(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: datas
            )
            print("Sync Data done")

            print("Sync Properties start")
            try JsonUploader.syncIntegrationProperties(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: properties
            )
            print("Sync Properties done")

            print("Sync Events start")
            try JsonUploader.syncIntegrationEvents(
                integrationId: integrationId,
                organizationId: organizationId,
                meta: events
            )
            print("Sync Events done")

            print("Sync Action:\(action.keyType) done")
        }

        print("Sync done")
    }

    static func syncIntegration(input: NativeItem) throws -> String {
        let semaphore = DispatchSemaphore(value: 0)
        var result: ResultModel<SyncIntegrationResultRawModel>?
        NetworkExecutor.getInstance().performOperation(
            NetworkOperation(
                JsonUploaderQuerys.syncIntegration(),
                operationName: "syncIntegration",
                variables: ["input": AnyEncodable(input)]
            )
        ) { (response: ResultModel<SyncIntegrationResultRawModel>) in
            result = response
            semaphore.signal()
        }
        semaphore.wait()
        switch result! {
        case .success(let raw):
            return raw.syncIntegration?.id ?? ""
        case .error(let errorModel):
            throw errorModel
        }
    }

    static func syncIntegrationData(
        integrationId: String, organizationId: String, meta: [DataNativeMeta]
    ) throws {
        if meta.isEmpty {
            return
        }
        let input = SyncIntegrationDataInput(
            integrationId: integrationId,
            organizationId: organizationId,
            data: meta
        )

        let semaphore = DispatchSemaphore(value: 0)
        var result: ResultModel<EmptyResultModel>?
        NetworkExecutor.getInstance().performOperation(
            NetworkOperation(
                JsonUploaderQuerys.syncIntegrationData(),
                operationName: "syncIntegrationData",
                variables: ["input": AnyEncodable(input)]
            )
        ) { (response: ResultModel<EmptyResultModel>) in
            result = response
            semaphore.signal()
        }
        semaphore.wait()
        switch result! {
        case .success(let raw):
            return
        case .error(let errorModel):
            throw errorModel
        }
    }

    static func syncIntegrationProperties(
        integrationId: String, organizationId: String, meta: [PropertyNativeMeta]
    ) throws {
        if meta.isEmpty {
            return
        }
        let input = SyncIntegrationPropertiesInput(
            integrationId: integrationId,
            organizationId: organizationId,
            properties: meta
        )

        let semaphore = DispatchSemaphore(value: 0)
        var result: ResultModel<EmptyResultModel>?
        NetworkExecutor.getInstance().performOperation(
            NetworkOperation(
                JsonUploaderQuerys.syncIntegrationProperties(),
                operationName: "syncIntegrationProperties",
                variables: ["input": AnyEncodable(input)]
            )
        ) { (response: ResultModel<EmptyResultModel>) in
            result = response
            semaphore.signal()
        }
        semaphore.wait()
        switch result! {
        case .success(let raw):
            return
        case .error(let errorModel):
            throw errorModel
        }
    }

    static func syncIntegrationEvents(
        integrationId: String, organizationId: String, meta: [EventNativeMeta]
    ) throws {
        if meta.isEmpty {
            return
        }
        let input = SyncIntegrationEventsInput(
            integrationId: integrationId,
            organizationId: organizationId,
            events: meta
        )

        let semaphore = DispatchSemaphore(value: 0)
        var result: ResultModel<EmptyResultModel>?
        NetworkExecutor.getInstance().performOperation(
            NetworkOperation(
                JsonUploaderQuerys.syncIntegrationEvents(),
                operationName: "syncIntegrationEvents",
                variables: ["input": AnyEncodable(input)]
            )
        ) { (response: ResultModel<EmptyResultModel>) in
            result = response
            semaphore.signal()
        }
        semaphore.wait()
        switch result! {
        case .success(let raw):
            return
        case .error(let errorModel):
            throw errorModel
        }
    }

    static func syncIntegrationSlots(
        integrationId: String, organizationId: String, meta: [SlotNativeMeta]
    ) throws {
        if meta.isEmpty {
            return
        }
        let input = SyncIntegrationSlotsInput(
            integrationId: integrationId,
            organizationId: organizationId,
            slots: meta
        )

        let semaphore = DispatchSemaphore(value: 0)
        var result: ResultModel<EmptyResultModel>?
        NetworkExecutor.getInstance().performOperation(
            NetworkOperation(
                JsonUploaderQuerys.syncIntegrationSlots(),
                operationName: "syncIntegrationSlots",
                variables: ["input": AnyEncodable(input)]
            )
        ) { (response: ResultModel<EmptyResultModel>) in
            result = response
            semaphore.signal()
        }
        semaphore.wait()
        switch result! {
        case .success(let raw):
            return
        case .error(let errorModel):
            throw errorModel
        }
    }
}
