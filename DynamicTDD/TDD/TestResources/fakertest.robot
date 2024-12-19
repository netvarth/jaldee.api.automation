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
Extract UUID Part
    # ${first_part}=    Evaluate    FakerLibrary.Get Faker Data  uuid4 | split('-')[0]
    # Log    ${first_part}

    ${token}=   FakerLibrary.Fake Data   lexify   ^[A-Za-z0-9]{20}$
    
    ${invoiceId}=  FakerLibrary.iana_id

    ${uuid}=    Evaluate    str(__import__('uuid').uuid4())
    ${first_part}=    Evaluate    '${uuid}'.split('-')[0]
    Log    ${first_part}

    ${first_part}=    Evaluate    str(__import__('uuid').uuid4()).split('-')[0]
    Log    ${first_part}




# Creating Service Names -1

    # ${first_part}=  Evaluate  '${FakerLibrary.Uuid4}'.split('-')[0]
    # ${first_part}=  Evaluate  FakerLibrary.Uuid4().split('-')[0]



*** COMMENTS ***

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


