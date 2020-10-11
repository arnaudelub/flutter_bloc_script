#! /bin/bash
#shopt -s xpg_echo
#########################
# Created by ArnauDelub #
#########################
freezed=false
injectable=false
while getopts "hfid:n:" opt; do
  case $opt in
    f) freezed=True   ;;
    i) injectable=True ;;
    h) echo "set flag -f to generate Bloc with freezed!"
       echo "set flag -i to use injectable!"
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

feature=''
delimiter=""
if [[ $FEATURE == *"_"* ]]; then
    delimiter="_"
elif [[ $FEATURE == *"-"* ]]; then
    delimiter="-"
fi
feat=$FEATURE
arrIN=(${feat//$delimiter/ })

for i in "${arrIN[@]}"; do
    feature+="${i^}"
done
echo "Creating file with class baseName: $feature"

bloc="$DIR${FEATURE}_bloc.dart"
event="$DIR${FEATURE}_event.dart"
state="$DIR${FEATURE}_state.dart"
cr=$'\n'

if [[ ! freezed ]];then
eventContent="
part of '${FEATURE}_bloc.dart';\n\n@immutable\nabstract class ${feature}Event {}"
stateContent="
part of '${FEATURE}_bloc.dart';\n\n\
@immutable\n\
abstract class ${feature}State {}\n\
class ${feature}Initial extends ${feature}State{}"
blocContent="import 'dart:async';\n\n"
blocContent="${blocContent}import 'package:bloc/bloc.dart'\n"
blocContent="${blocContent}import 'package:meta/meta.dart';\n"
if [[ injectable ]]; then
    blocContent="${blocContent}import 'package:injectable/injectable.dart';\n\n"
fi
blocContent="${blocContent}part '${FEATURE}_event.dart'\n"
blocContent="${blocContent}part '${FEATURE}_state.dart';\n\n"
if [[ injectable ]]; then
    blocContent="${blocContent}@injectable\n"
fi
blocContent="${blocContent}class ${feature}Bloc extends Bloc<${feature}Event, ${feature}State>{\n"
blocContent="${blocContent}\t${feature}Bloc():super(const ${feature}State.initial());\n"
blocContent="${blocContent}\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\tStream<${feature}State> mapEventToState(\n"
blocContent="${blocContent}\t\t${feature}Event event,\n"
blocContent="${blocContent}\t) async* {\n"
blocContent="${blocContent}\t\t//TODO implement\n"
blocContent="${blocContent}\t}\n"
blocContent="${blocContent}}"
else

eventContent="
part of '${FEATURE}_bloc.dart';\n\n \
@freezed\n \
abstract class ${feature}Event with _\$${feature}Event { \n \
\t const factory ${feature}Event.() = ;\n \
}"
stateContent="
part of '${FEATURE}_bloc.dart';\n\n \
@freezed\n \
abstract class ${feature}State with _\$${feature}State { \n \
\t const factory ${feature}State.initial() = Initial;\n \
}"
blocContent="import 'dart:async';\n\n"
blocContent="${blocContent}import 'package:freezed_annotation/freezed_annotation.dart';\n"
blocContent="${blocContent}import 'package:bloc/bloc.dart';\n"
blocContent="${blocContent}import 'package:meta/meta.dart';\n"
if [[ injectable ]]; then
    blocContent="${blocContent}import 'package:injectable/injectable.dart';\n\n"
fi
blocContent="${blocContent}part '${FEATURE}_event.dart';\n"
blocContent="${blocContent}part '${FEATURE}_state.dart';\n\n"
blocContent="${blocContent}part '${FEATURE}_bloc.freezed.dart';\n\n"
if [[ injectable ]]; then
    blocContent="${blocContent}@injectable\n"
fi
blocContent="${blocContent}class ${feature}Bloc extends Bloc<${feature}Event, ${feature}State>{\n"
blocContent="${blocContent}\t${feature}Bloc():super(const ${feature}State.initial());\n"
blocContent="${blocContent}\n"
blocContent="${blocContent}\t@override\n"
blocContent="${blocContent}\tStream<${feature}State> mapEventToState(\n"
blocContent="${blocContent}\t\t${feature}Event event,\n"
blocContent="${blocContent}\t) async* {\n"
blocContent="${blocContent}\t\t//TODO implement\n"
blocContent="${blocContent}\t}\n"
blocContent="${blocContent}}"
fi
echo "Creating ${event}_event.dart file"
echo -e $eventContent > $event
echo "Creating ${bloc}_bloc.dart file"
echo -e $blocContent > $bloc
echo "Creating ${state}_state.dart file"
echo -e $stateContent > $state
echo "Done!"
