*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Basics
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Variables ***
@{Views}  self  all  customersOnly
${CAUSERNAME}             admin.support@jaldee.com
${PASSWORD}               Netvarth12
${NEWPASSWORD}            Jaldee12
${SPASSWORD}              Netvarth1
${test_mail}              test@jaldee.com
${count}                  ${1}
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py

*** Test Cases ***

JD-TC-Change Password-1
    Log  ${var_file}
    ${cust_pro}=  Evaluate  random.choice(list(open($var_file)))  random
    Log  ${cust_pro}
    ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    ${var} 	${ph}=   Split String    ${cust_pro}  =  
    Set Suite Variable  ${ph}