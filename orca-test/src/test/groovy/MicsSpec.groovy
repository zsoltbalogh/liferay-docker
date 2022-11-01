import java.util.concurrent.TimeUnit

/**
 * @author Josef Sustacek
 */
class MicsSpec extends BaseOrcaSpec {

    def "'' (no command) should print a help message and return error"() {
        when:
            def orcaRun = orca.startOrca([:], '')
        
            orcaRun.waitFor(15, TimeUnit.SECONDS)

            def stdout = orcaRun.inputStream.getText('utf-8')

        then:
            !orcaRun.isAlive()
            orcaRun.exitValue() != 0

            stdout.contains('Usage: orca <command>')
            stdout.contains('all: ')
            stdout.contains('build: ')
            stdout.contains('up: ')

        cleanup:
            orcaRun.destroyForcibly()
            dumpOrcaStdoutToFile(stdout)
    }

}
