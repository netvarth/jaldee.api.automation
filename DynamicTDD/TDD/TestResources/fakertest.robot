# Test Timeout      1 minute
# Import Library    FakerLibrary    locale=de_DE    providers=${None}    seed=124
*** Settings ***
Force Tags        faker
Library           FakerLibrary
Library         Collections
Library           /ebs/TDD/CustomKeywords.py


*** Variables ***
@{service_names}

*** Test Cases ***
Creating Service Names -1

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}


Creating Service Names -2

    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}
    Log  ${service_names}
    
*** COMMENTS ***
    ${name}=    generate_service_name
    ${name}=    generate_service_name
    ${name}=    generate_service_name
    ${name}=    generate_service_name
    ${name}=    generate_service_name
    ${name}=    generate_service_name
    ${name}=    generate_service_name


    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name
    ${name}=    generate_long_service_name


