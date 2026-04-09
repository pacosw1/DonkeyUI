import Foundation

#if canImport(MetricKit)
import MetricKit

@available(iOS 15.0, macOS 12.0, *)
public final class DonkeyMetricKitReporter: NSObject, MXMetricManagerSubscriber {
    private let diagnosticsReporter: DonkeyDiagnosticsReporter

    public init(diagnosticsReporter: DonkeyDiagnosticsReporter) {
        self.diagnosticsReporter = diagnosticsReporter
        super.init()
        MXMetricManager.shared.add(self)
    }

    deinit {
        MXMetricManager.shared.remove(self)
    }

    public func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            Task {
                await diagnosticsReporter.reportDiagnostic(
                    type: .performance,
                    category: "metrickit_metric_payload",
                    message: "Received MetricKit metric payload",
                    level: .info,
                    metadata: metricMetadata(for: payload)
                )
            }
        }
    }

    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            Task {
                await diagnosticsReporter.reportDiagnostic(
                    type: .crash,
                    category: "metrickit_diagnostic_payload",
                    message: "Received MetricKit diagnostic payload",
                    level: .error,
                    metadata: diagnosticMetadata(for: payload)
                )
            }
        }
    }

    private func metricMetadata(for payload: MXMetricPayload) -> [String: String] {
        var metadata: [String: String] = [
            "payload_type": "metric",
        ]

        if let json = jsonString(from: payload.jsonRepresentation()) {
            metadata["payload_json"] = json
        }

        return metadata
    }

    private func diagnosticMetadata(for payload: MXDiagnosticPayload) -> [String: String] {
        var metadata: [String: String] = [
            "payload_type": "diagnostic",
        ]

        if let json = jsonString(from: payload.jsonRepresentation()) {
            metadata["payload_json"] = json
        }

        metadata["has_crash_diagnostics"] = boolLabel(payload.crashDiagnostics?.isEmpty == false)
        metadata["has_hang_diagnostics"] = boolLabel(payload.hangDiagnostics?.isEmpty == false)
        metadata["has_cpu_exception_diagnostics"] = boolLabel(payload.cpuExceptionDiagnostics?.isEmpty == false)
        metadata["has_disk_write_exception_diagnostics"] = boolLabel(payload.diskWriteExceptionDiagnostics?.isEmpty == false)

        return metadata
    }

    private func jsonString(from data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }

    private func boolLabel(_ value: Bool) -> String {
        value ? "true" : "false"
    }
}
#endif
