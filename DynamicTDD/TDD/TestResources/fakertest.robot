# Test Timeout      1 minute
# Import Library    FakerLibrary    locale=de_DE    providers=${None}    seed=124
*** Settings ***
Force Tags        faker
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py

*** Test Cases ***
Import With Providers
    # Import Library    FakerLibrary   providers=faker_microservice
    # ${name}=    FakerLibrary.microservice
    # Log  ${name}
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