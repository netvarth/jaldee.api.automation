*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
# Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}      0
@{emptylist}
${en_temp_name}   EnquiryName
${consumernumber}     55500000032
${locId}  207
@{custdeets}  firstname  lastname  phoneNo  countryCode  gender
${p1_l2}   ${425}


*** Keywords ***

# test Keyword
# Set TZ Header
#     [Arguments]    &{kwargs}
#     # ${params}=  Create Dictionary  account=${accid}
#     ${tzheaders}=    Create Dictionary  
#     Log  ${kwargs}
#     ${x} =    Get Variable Value    ${kwargs}   
#     # ${value}=   Evaluate   $kwargs.get("timeZone")
#     # ${value}=   Evaluate   $kwargs.get("location")
#     IF  ${x}=={} or '${kwargs.get("timeZone")}'=='${None}' or '${kwargs.get("location")}'=='${None}'
#         Set To Dictionary 	${tzheaders} 	timeZone=Asia/Kolkata
#         Log  ${tzheaders}
#     ELSE
#         FOR    ${key}    ${value}    IN    &{kwargs}
#             # IF  '${key}' in 'timeZone', 'timezone'
#             # IF  '${kwargs.get("timeZone")}'!='${None}' or '${kwargs.get("timezone")}'!='${None}'
#             # IF  '${key}'=='timeZone' or '${key}'=='timezone'
#             IF  "${key}".lower()=="timezone"
#                 Set To Dictionary 	${tzheaders} 	timeZone=${value}
#                 Remove From Dictionary 	&{kwargs} 	${key}
#                 Log  ${tzheaders}
#             ELSE IF  '${key}' == 'location'
#                 Set To Dictionary 	${params}   ${key}=${value}
#                 Remove From Dictionary 	&{kwargs} 	${key}
#                 Log  ${params}
#             END
#         END
#     END
    
    
#     Log  ${kwargs}
#     [Return]  ${tzheaders}  ${kwargs}

# ${data}= | Create dictionary | key1=one | key2=two
    # ${value}= | Evaluate | $data.get("key3", "default value")

    # ${x} =    Get Variable Value    ${kwargs}   
    # IF  ${x}=={} 
    #     Set To Dictionary 	${cons_headers} 	timeZone=Asia/Kolkata
    # END
    # FOR    ${key}    ${value}    IN    &{kwargs}
    #     IF  '${key}' in 'timeZone', 'timezone'
    #         Set To Dictionary 	${cons_headers} 	timeZone=${value}
    #     ELSE IF  '${key}' == 'location'
    #         Set To Dictionary 	${params}   ${key}=${value}
    #     END
    # END

Get Consumer test
    [Arguments]    &{params}
    Check And Create YNW Session
    # Set To Dictionary  ${form_headers}   timeZone=${timeZone}
    # ${headers}  ${params}=  Set TZ Header  &{params}
    ${tzheaders}  ${params}  ${locparam}=  Set TZ Header  &{params}
    Set To Dictionary  ${cons_headers}   &{headers}
    Set To Dictionary  ${params}   &{locparam}
    Log   ${cons_headers}
    ${resp}=    GET On Session    ynw   /consumer    params=${params}    expected_status=any   headers=${cons_headers}
    [Return]  ${resp}

    

Get Consumer Communications test
    [Arguments]   &{kwargs}  #${timeZone}=Asia/Kolkata
    ${tzheaders}  ${kwargs}  ${locparam}=  Set TZ Header  &{kwargs}
    Log  ${kwargs}
    Set To Dictionary  ${cons_headers}   &{tzheaders}
    Set To Dictionary  ${params}   &{locparam}
    Check And Create YNW Session
    ${resp}=  GET On Session  ynw  /consumer/communications   params=${params}  expected_status=any   headers=${cons_headers}
    [Return]  ${resp}


*** Test Cases ***

# Login test
#     ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME7}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200 

    
TC-1

    # ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    # ${tz1}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    
    # test Keyword   456  
    # test Keyword   456  timeZone=${tz1}
    # test Keyword   456  account=456
    # test Keyword   456  account=456   location=${{str('${p1_l2}')}}  timezone=${tz1}
    # test Keyword   456  account=456   location=${{str('${p1_l2}')}}  timeZone=${tz1}
    # test Keyword   456  location=${{str('${p1_l2}')}}
    
    ${resp}=  Consumer Login  5550075595  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${a_id}=  get_acc_id  ${PUSERNAME2}
    # ${msg}=  Fakerlibrary.sentence
    # ${resp}=  General Communication with Provider   ${msg}   ${a_id}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Consumer Communications test
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}

    ${resp}=  Get Consumer test  primaryMobileNo-eq=5550075595   location=${{str('${p1_l2}')}}
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # test Keyword   456  location=422
    # test Keyword   456  location=422  timeZone=${tz1}
    # ${gender}    Random Element    ${Genderlist}
    # ${profile}=  FakerLibrary.profile   sex=female
    # Set Test Variable  ${custid}   0
    # ${Custfname}=  FakerLibrary.name
    # ${Custlname}=  FakerLibrary.last_name
    # # ${gender}    Random Element    ${Genderlist}
    # ${kyc_list1}=  Create Dictionary  isCoApplicant=${bool[0]}
    
    # Verify Phone and Create Loan Application with customer details  ${consumernumber}  ${OtpPurpose['ConsumerVerifyPhone']}  ${custid}  ${locId}  ${kyc_list1}  firstname=${Custfname}  lastname=${Custlname}  phoneNo=${consumernumber}  countryCode=${countryCodes[0]}  gender=${gender}

*** Comment ***
JD-TC-ChangeEnqStatus-1

    ${resp}=   Encrypted Provider Login  ${PUSERNAME32}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Leads With Filter    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

