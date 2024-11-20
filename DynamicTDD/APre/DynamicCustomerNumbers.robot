*** Settings ***

Force Tags        Customer Numbers
Library           Collections
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py


***Variables***
${CUSERPH}      ${CUSERNAME}


*** Test Cases ***
Clear Files
    Remove Files   ${EXECDIR}/TDD/varfiles/consumerlist.py
    Create File   ${EXECDIR}/TDD/varfiles/consumerlist.py
    Remove Files   ${EXECDIR}/data/TDD_Logs/aprenumbers.txt
    Create File   ${EXECDIR}/data/TDD_Logs/aprenumbers.txt

JD-TC-Generate Customer Number-1
    [Documentation]   Generate customer numbers

    Set Suite Variable  ${US}  0
    FOR  ${c_count}  IN RANGE  ${consumer_count} 
        ${CUSERPH}=  Evaluate  ${CUSERPH}+1
        Append To File  ${EXECDIR}/TDD/varfiles/consumerlist.py  CUSERNAME${US}=${CUSERPH}${\n}
        Append To File  ${EXECDIR}/data/TDD_Logs/aprenumbers.txt  ${CUSERPH}${\n}
        ${US} =  Evaluate  ${US}+1
        Set Suite Variable  ${US}
    END
    Log  \n${c_count+1} customer numbers generated    console=yes   