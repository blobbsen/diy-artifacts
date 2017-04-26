matrixJob('openBSC_jobDSL') {

  	axes {
        text('IU', '--enable-iu', '--disable-iu')
      	label('label', 'masterSlave')
    }

  	label('masterSlave')

  	scm {
      git{
       	remote {
            url('git://git.osmocom.org/openbsc')
        }
        branch('origin/master')
        extensions {
        	cleanBeforeCheckout()
          	// "Force Polling from Workspace" is missing
        }
      }
    }

  	steps {
      	shell('''
				docker run --rm=true \
				  \
   				-e HOME=/build \
    			-e MAKE=make \
    			-e PARALLEL_MAKE="$PARALLEL_MAKE" \
    			-e IU="$IU" \
    			-e SMPP="$SMPP" \
    			-e MGCP="$MGCP" \
    			-e PATH="$PATH:/build_bin" \
    			\
    			-v $PWD:/build \
    			-v "$HOME/bin:/build_bin" \
    			\
    			-v "$HOME/osmo-ci/scripts/osmo-build-dep.sh:/build_bin/osmo-build-dep.sh" \
    			-v "$HOME/osmo-ci/scripts/cat-testlogs.sh:/build_bin/cat-testlogs.sh" \
    			-v "$HOME/osmo-ci/scripts/osmo-deps.sh:/build_bin/osmo-deps.sh" \
    			\
    			osmocom:amd64 /build/contrib/jenkins.sh
			  '''.stripIndent())
    }

  	publishers {
        warnings(['GNU C Compiler 3 (gcc)'], ['GNU C Compiler 3 (gcc)': '*']) {
        }
    }

}
