*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Variables ***

${self}     0
@{service_names}
${jpgfile}      /ebs/TDD/uploadimage.jpg
${order}        0
${fileSize}     0.00458
${pdffile}      /ebs/TDD/sample.pdf
${domain}       healthCare
${subdomain}    dentists
${MEET_URL}    https://meet.google.com/{meeting_id}
@{service_duration}  10  20  30   40   50

*** Test Cases ***

JD-TC-Schedule-1

    [Documentation]  Schedule workflow for pre deployment.

    ${firstname}  ${lastname}  ${PUSERNAME_B}  ${LoginId}=  Provider Signup   Domain=${domain}   SubDomain=${subdomain}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${pdrname}  ${decrypted_data['userName']}

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']} 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Disable Appointment   ${toggle[0]}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ........ Location Creation .......

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    # ........ Service Creations ............

    #  1. Create Service without Prepayment.

    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id1}=  Create Sample Service  ${SERVICE1}   
    
    #  2. Create Service without Prepayment and Max Bookings Allowed > 1

    ${SERVICE2}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE2}   
    ${s_id2}=  Create Sample Service  ${SERVICE2}      maxBookingsAllowed=10
    
    #  3. Create Service with Fixed Prepayment

    ${SERVICE3}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE3}   
    ${min_pre3}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${s_id3}=  Create Sample Service  ${SERVICE3}   isPrePayment=${bool[1]}   minPrePaymentAmount=${min_pre3} 
   
    #  4. Create Service with Percentage Prepayment

    ${SERVICE4}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE4}   
    ${min_pre4}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${s_id4}=  Create Sample Service  ${SERVICE4}   isPrePayment=${bool[1]}   prePaymentType=${advancepaymenttype[0]}  minPrePaymentAmount=${min_pre4} 
   
    #  5. Create Taxable Service

    ${SERVICE5}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE5}   
    ${s_id5}=  Create Sample Service  ${SERVICE5}   taxable=${bool[1]} 
   
    #  6. Create Service with Lead Time

    ${SERVICE6}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE6}  
    ${leadTime}=   Random Int   min=1   max=5 
    ${s_id6}=  Create Sample Service  ${SERVICE6}    leadTime=${leadTime}
   
    #  7. Create Service with International Pricing

    ${SERVICE7}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE7}
    ${intlamt}=  Pyfloat  right_digits=1  min_value=250  max_value=500
    ${s_id7}=  Create Sample Service  ${SERVICE7}  supportInternationalConsumer=${bool[1]}  internationalAmount=${intlamt}
   
    #  8. Create Service with Dynamic Pricing

    ${SERVICE8}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE8}  
    ${leadTime}=   Random Int   min=1   max=5 
    ${s_id8}=  Create Sample Service  ${SERVICE8}    priceDynamic=${bool[1]}
 
    #  9. Create Virtual Service with Audio Only

    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[2]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[0]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE9}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE9}
    ${resp}=  Create Service  ${SERVICE9}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id9}  ${resp.json()}

    #  10. Create Virtual Service with Video Only

    ${meeting_id}=   FakerLibrary.lexify  text='???-????-???'  letters=${lower}
    ${GoogleMeet_url}=     Format String    ${MEET_URL}    meeting_id=${meeting_id}
    Log    ${meet_url}
    
    ${Description1}=    FakerLibrary.sentences
    ${instructions2}=   FakerLibrary.sentence
    ${VScallingMode1}=   Create Dictionary   callingMode=${CallingModes[3]}   value=${GoogleMeet_url}   status=${status[0]}    instructions=${Description1[0]}${\n}${Description1[1]}${\n}${Description1[2]}
    ${VScallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${PUSERNAME_B}   countryCode=${countryCodes[0]}  instructions=${instructions2} 
    ${virtualCallingModes}=  Create List  ${VScallingMode1}  ${VScallingMode2}
    ${vstype}=   Set Variable   ${vservicetype[1]}

    ${description}=    FakerLibrary.sentence
    ${min_pre}=   Pyfloat  right_digits=1  min_value=10  max_value=50
    ${Total}=  Pyfloat  right_digits=1  min_value=100  max_value=500
    ${SERVICE10}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE10}
    ${resp}=  Create Service  ${SERVICE10}  ${description}  ${service_duration[1]}  ${bool[0]}  ${Total}  ${bool[0]}  serviceType=${ServiceType[0]}  virtualServiceType=${vstype}  virtualCallingModes=${virtualCallingModes}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id10}  ${resp.json()}

    # ......Get All Services ..............

    ${resp}=   Get Service By Id  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id7}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id8}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id9}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Service By Id  ${s_id10}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ...... Create Schedule ........

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=5
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  
    ...   ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    # .......Update Schedule .......

    ${parallel}=  FakerLibrary.Random Int  min=6  max=10
    ${resp}=  Update Appointment Schedule  ${sch_id}  ${resp.json()['name']}  ${resp.json()['apptSchedule']['recurringType']}  ${resp.json()['apptSchedule']['repeatIntervals']}
    ...  ${resp.json()['apptSchedule']['startDate']}  ${resp.json()['apptSchedule']['terminator']['endDate']}  ${resp.json()['apptSchedule']['timeSlots'][0]['sTime']}
    ...  ${resp.json()['apptSchedule']['timeSlots'][0]['eTime']}  ${parallel}  ${parallel}  ${lid}  ${resp.json()['timeDuration']}  ${bool[1]}  
    ...  ${s_id1}  ${s_id2}  ${s_id3}  ${s_id4}  ${s_id5}  ${s_id6}  ${s_id7}  ${s_id8}  ${s_id9}  ${s_id10} 

    # .......Disable Schedule .......

    ${resp}=  Enable Disable Appointment Schedule  ${sch_id}  ${Qstate[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
