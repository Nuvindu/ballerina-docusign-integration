import ballerina/io;
import ballerina/lang.array;
import ballerinax/docusign.dsesign;

configurable string accountId = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string refreshUrl = ?;
configurable string serviceUrl = ?;

public function main() returns error? {
    dsesign:Client docusign = check new (
        serviceUrl,
        {
            auth: {
                clientId,
                clientSecret,
                refreshToken,
                refreshUrl
            }
        }
    );

    string base64Encoded = array:toBase64(check io:fileReadBytes("./resources/README.pdf"));
    string documentId = "1";

    dsesign:EnvelopeDefinition agreement = {
        documents: [
            {
                documentBase64: base64Encoded,
                documentId: documentId,
                fileExtension: "pdf",
                name: "document"
            }
        ],
        emailSubject: "Vehicle Purchase Agreement - McLaren MP4/2",
        recipients: {
            signers: [
                {
                    email: "add-recipient-email-here",
                    name: "add-recipient-name",
                    recipientId: "12",
                    tabs: {
                        signHereTabs: [
                            {
                                xPosition: "300",
                                yPosition: "200",
                                documentId: documentId,
                                pageNumber: "1",
                                height: "10"
                            }
                        ]
                    }
                }
            ]
        },
        status: "sent"
    };

    dsesign:EnvelopeSummary agreementResult = check docusign->/accounts/[accountId]/envelopes.post(agreement);
    io:println("Agreement Status: ", agreementResult.status);

    string? envelopeId = agreementResult.envelopeId;
    if envelopeId is () {
        return error("Envelope ID is not available");
    }
    io:println("Envelope ID", envelopeId);

    dsesign:Envelope agreementStatus = check docusign->/accounts/[accountId]/envelopes/[envelopeId];
    io:println("Current Status: ", agreementStatus.status);
}
