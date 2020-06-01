#! /bin/bash
#shopt -s xpg_echo

freezed=false
while getopts "hfd:n:" opt; do
  case $opt in
    f) freezed=True   ;;
    h) echo "set flag -f to generate Bloc with freezed!"
       echo "set flag -d with the full path where you want to create the bloc"
       echo "set flag -n with the name of the feature"
       exit 1 ;;
    d) DIR=$OPTARG ;;
    n) FEATURE=$OPTARG ;;
    \?)
	   echo "Use the -h flag to get help"
	   exit
	   ;;
    *) echo 'error'
       exit 1
  esac
done

if [ ! -d "$DIR" ]; then
    echo 'Option -d missing or designates non-directory' >&2
    exit 1
fi

if [ -z "${FEATURE}" ]; then
    echo "Missing the option -n for the name of the feature"
    exit 1
fi
bloc="$DIR${FEATURE}_bloc.dart"
event="$DIR${FEATURE}_event.dart"
state="$DIR${FEATURE}_state.dart"
cr=$'\n'

if [[ ! freezed ]];then
eventContent="
part of '${FEATURE}_bloc.dart';\n\n@immutable\nabstract class ${FEATURE^}Event {}"
stateContent="
part of '${FEATURE}_bloc.dart';\n\n\
@immutable\n\
abstract class ${FEATURE^}State {}\n\
class ${FEATURE^}Initial extends ${FEATURE^}State{}"
blocContent="import 'dart:async';\n\n"
blocContent="${blocContent}import 'package:bloc/bloc.dart'\n"
blocContent="${blocContent}import 'package:meta/meta.dart';\n\n"
blocContent="${blocContent}part '${FEATURE}_event.dart'\n"
blocContent="${blocContent}part '${FEATURE}_state.dart';\n\n"
blocContent="${blocContent}class ${FEATURE^}Bloc extends Bloc<${FEATURE^}Event, ${FEATURE^}State>{\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\t${FEATURE^}State get initialState => ${FEATURE^}Initial();\n"
blocContent="${blocContent}\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\tStream<${FEATURE^}State> mapEventToState(\n"
blocContent="${blocContent}\t\t${FEATURE^}Event event,\n"
blocContent="${blocContent}\t) async* {\n"
blocContent="${blocContent}\t\t//TODO implement\n"
blocContent="${blocContent}\t}\n"
blocContent="${blocContent}}"
else

eventContent="
part of '${FEATURE}_bloc.dart';\n\n \
@freezed\n \
abstract class ${FEATURE^}Event wih _$${FEATURE^}Event { \n \
\t const factory ${FEATURE^}Event.() = ;
}"
stateContent="
part of '${FEATURE}_bloc.dart';\n\n \
@freezed\n \
abstract class ${FEATURE^}State wih _$${FEATURE^}State { \n \
\t const factory ${FEATURE^}State.initial() = Initial;
}"
blocContent="import 'dart:async';\n\n"
blocContent="${blocContent}import 'package:freezed_annotation/freezed_annotation.dart';"
blocContent="${blocContent}import 'package:bloc/bloc.dart'\n"
blocContent="${blocContent}import 'package:meta/meta.dart';\n\n"
blocContent="${blocContent}part '${FEATURE}_event.dart'\n"
blocContent="${blocContent}part '${FEATURE}_state.dart';\n\n"
blocContent="${blocContent}class ${FEATURE^}Bloc extends Bloc<${FEATURE^}Event, ${FEATURE^}State>{\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\t${FEATURE^}State get initialState => const ${FEATURE^}State.initial();\n"
blocContent="${blocContent}\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\tStream<${FEATURE^}State> mapEventToState(\n"
blocContent="${blocContent}\t\t${FEATURE^}Event event,\n"
blocContent="${blocContent}\t) async* {\n"
blocContent="${blocContent}\t\t//TODO implement\n"
blocContent="${blocContent}\t}\n"
blocContent="${blocContent}}"
fi
echo -e $eventContent > $event
echo -e $blocContent > $bloc
echo -e $stateContent > $state
