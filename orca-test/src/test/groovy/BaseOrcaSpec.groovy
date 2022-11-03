

import spock.lang.Shared
import spock.lang.Specification
import test.DockerOrca
import test.NativeOrca
import test.Orca
import test.OrcaRun

import java.time.Duration
import java.util.concurrent.TimeUnit

/**
 * @author Josef Sustacek
 */
class BaseOrcaSpec extends Specification {
    static def ORCA_TEST_RUNTIME_IMPL = System.getProperty('ORCA_TEST__RUNTIME_IMPL')

    @Shared
    Orca orca = switch (ORCA_TEST_RUNTIME_IMPL) {
        case 'docker' -> yield new DockerOrca()
        case 'native' -> yield new NativeOrca()
        default -> throw new IllegalArgumentException("Orca test runtime '${ORCA_TEST_RUNTIME_IMPL}' unknown.")
    }

    // Each feature will run Orca at-most once, this object will hold the reference to the process
    OrcaRun featureOrcaRun

    def setupSpec() {
        orca.setupSpec()
    }

    def cleanupSpec() {
        orca.cleanupSpec()
    }

    def setup() {
        def specName = specificationContext.currentSpec.name
        def featureName = specificationContext.currentFeature.displayName
        def iterationIndex = specificationContext.currentIteration.iterationIndex

        orca.setup(specName, featureName, iterationIndex)
    }

    def cleanup() {
        def specName = specificationContext.currentSpec.name
        def featureName = specificationContext.currentFeature.displayName
        def iterationIndex = specificationContext.currentIteration.iterationIndex

        orca.cleanup(specName, featureName, iterationIndex, featureOrcaRun)
    }

    OrcaRun startOrcaAndWatchIt(Duration timeout, Map envVars, String... orcaArgs) {
        def orcaArgsList = (orcaArgs ? orcaArgs.toList() : [])

        def orcaProcess = orca.startOrca(envVars, orcaArgsList)

        orcaProcess.waitFor(timeout.toMillis(), TimeUnit.MILLISECONDS)

        def stdout = orcaProcess.inputStream.getText('utf-8')

        orcaProcess.destroyForcibly()

        featureOrcaRun = new OrcaRun(envVars, orcaArgsList, orcaProcess, stdout)

        return featureOrcaRun
    }

}
