#!/bin/bash

ls -l */*state* */.*lock* */.terraform */secret.tfvars */secret.json
rm -fr */*state* */.*lock*  */.terraform */secret.tfvars */secret.json