import java.time.Duration

/**
 * @author Josef Sustacek
 */
class MicsSpec extends BaseOrcaSpec {

    def "'' (no command) should print a help message and return error"() {
        when:
            def orcaRun =
                startOrcaAndWatchIt(
                        Duration.ofSeconds(5),
                        [:],
                        '')

        then:
            orcaRun.process.exitValue() != 0

            def stdout = orcaRun.stdout

            stdout.contains('Usage: orca <command>')
            stdout.contains('all: ')
            stdout.contains('build: ')
            stdout.contains('up: ')
    }

}
