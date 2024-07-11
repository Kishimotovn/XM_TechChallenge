import Foundation
import ConfigConstant
import ComposableArchitecture
import Models

public extension APIClient {
    static var live: APIClient {
        @Dependency(ConfigConstant.self) var config
        let restClient = RestClient(baseURL: config.apiBaseURL)

        return .init(
            getQuestions: {
                let requestData = RequestData("questions")
                let response: GetQuestionsOutput = try await restClient.request(requestData)
                return response.map(Question.init)
            },
            submitQuestion: { questionID, answer in
                let input = SubmitQuestionInput(id: questionID, answer: answer)
                let requestData = try RequestData(
                    "/question/submit",
                    httpMethod: .post,
                    jsonBody: input
                )
                _ = try await restClient.request(requestData)
            }
        )
    }
}
