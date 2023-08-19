*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        MassCommunication
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
#Library           /ebs/TDD/messagesapi.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${waitlistedby}           PROVIDER
${SERVICE1}               SERVICE1
${SERVICE2}               SERVICE2
${SERVICE3}               SERVICE3
${SERVICE4}               SERVICE4
${SERVICE5}               SERVICE3
${SERVICE6}               SERVICE4
${CUSERPH}                ${CUSERNAME}
${jpgfile}     /ebs/TDD/uploadimage.jpg
${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf

*** Test Cases ***

JD-TC-ConsumerMassCommunication-1
    [Documentation]   Provider setting consumer mass communication
     
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+180521
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${CUSERPH0}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${CUSERPH0}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    # ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    # Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    # Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${multilocdoms}=  get_mutilocation_domains
    Log  ${multilocdoms}
    Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
    Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+55688520
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_B}${\n}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_B}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_B}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph1}=  Evaluate  ${PUSERNAME_B}+15566122
    ${ph2}=  Evaluate  ${PUSERNAME_B}+25566122
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${resp}=  Update Business Profile with Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${businessName }      ${resp.json()['businessName']}

    ${resp}=  Get Consumer By Id  ${CUSERPH0}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${jdconID}   ${resp.json()['userProfile']['id']}
    Set Suite Variable  ${fname}   ${resp.json()['userProfile']['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['userProfile']['lastName']}

    ${resp}=  AddCustomer  ${CUSERPH0}   firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${CUR_DAY}
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${resp}=   Create Sample Service  ${SERVICE3}
    Set Suite Variable    ${ser_id3}    ${resp}  
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    sleep   5s
    ${msg}=  FakerLibrary.sentence
    Set Suite Variable  ${msg}

    # ${resp}=  Get bsconf Messages
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}   200
    # ${MassCommunication}=  Set Variable   ${resp.json()['MassCommunication']} 
    # ${defreshedule_checkin_msg}=  Set Variable   ${resp.json()['reshedule_provider_notify_checkin']} 

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${MassCommunication}=  Set Variable   ${resp.json()['checkinMessages']['massCommunication']['Consumer_APP']} 
    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}  ${msg}    ${fileswithcaption}    ${wid1}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${MassCommunication1}=  Replace String  ${MassCommunication}  [consumer]       ${fname} ${lname}
    # ${MassCommunication1}=  Replace String  ${MassCommunication1}  [service]       ${SERVICE1}
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [type]       booking
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [message]       ${msg}
    ${MassCommunication1}=  Replace String  ${MassCommunication1}  [brandName]     ${businessName}

    Set Suite Variable   ${MassCommunication1}
    Log   ${MassCommunication1}
 
    ${MassCommunication2}=  Replace String  ${MassCommunication}  [consumer]       ${fname} ${lname}
    # ${MassCommunication2}=  Replace String  ${MassCommunication2}  [service]       ${SERVICE2}
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [type]       booking
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [message]       ${msg}
    ${MassCommunication2}=  Replace String  ${MassCommunication2}  [brandName]     ${businessName}

    Set Suite Variable   ${MassCommunication2}

    sleep  3s


     
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${wid2}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${MassCommunication2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Login  ${CUSERPH0}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   3s
    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[2]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[2]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[2]['attachements']}       []
    Should Contain 	${resp.json()[2]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[2]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[2]['attachements'][1]}   thumbPath


    Should Be Equal As Strings  ${resp.json()[3]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[3]['waitlistId']}         ${wid2}
    Should Be Equal As Strings  ${resp.json()[3]['msg']}                ${MassCommunication2}
    Should Be Equal As Strings  ${resp.json()[3]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[3]['attachements']}       []
    Should Contain 	${resp.json()[3]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[3]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[3]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_consumer_msgs  ${CUSERPH0}
    clear_provider_msgs  ${PUSERNAME_B}

JD-TC-ConsumerMassCommunication-2
    [Documentation]  Provider sending another consumer mass communication with one waitlist id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    #Log   ${msg}


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[1]}   ${bool[1]}  ${msg}    ${fileswithcaption}    ${wid1}  
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${msg}  ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep  2s
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Login  ${CUSERPH0}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid1}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${MassCommunication1}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    Should Contain 	${resp.json()[0]}   attachements
    ${attachment-len}=  Get Length  ${resp.json()[0]['attachements']}
    Should Be Equal As Strings  ${attachment-len}  3

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][0]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][0]['s3path']}   .png
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][0]['caption']}     ${caption1}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption2}

    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   s3path
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]['attachements'][1]}   thumbPath
    # Should Contain  ${resp.json()[0]['attachements'][1]['s3path']}   .jpg
    # Should Be Equal As Strings  ${resp.json()[0]['attachements'][1]['caption']}     ${caption3}

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    

JD-TC-ConsumerMassCommunication-3
    [Documentation]  Provider sending another consumer mass communication with all medium set as false
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_consumer_msgs  ${CUSERPH0}
    clear_provider_msgs  ${PUSERNAME_B}


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    #${msg}=  FakerLibrary.sentence
   
    # ${msg}=  FakerLibrary.sentence
   
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}  ${msg}    ${fileswithcaption}    ${wid1}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  #  Log   ${resp.json()}
  #  Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get provider communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    #Should Be Equal As Strings  ${resp.json()}        []
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid1}
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${MassCommunication1}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${wid2}
    # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${MassCommunication2}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []

    ${resp}=  Consumer Login  ${CUSERPH0}   ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Should Be Equal As Strings  ${resp.json()}        []
    # Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[0]['waitlistId']}         ${wid1}
    # Should Be Equal As Strings  ${resp.json()[0]['msg']}                ${MassCommunication1}
    # Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}     ${jdconID} 
    # Should Be Equal As Strings  ${resp.json()[0]['attachements']}       []
    # Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}        0
    # Should Be Equal As Strings  ${resp.json()[1]['waitlistId']}         ${wid2}
    # Should Be Equal As Strings  ${resp.json()[1]['msg']}                ${MassCommunication2}
    # Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}     ${jdconID}
    # Should Be Equal As Strings  ${resp.json()[1]['attachements']}       []

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-ConsumerMassCommunication-UH1
    [Documentation]  Provider sending another consumer mass communication without communication msg
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${bool[0]}  ${EMPTY}    ${fileswithcaption}    ${wid1}  ${wid2}
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${EMPTY}  ${wid1}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${MASS_COMMUNICATION_NOT_EMPTY}"

JD-TC-ConsumerMassCommunication-UH2
    [Documentation]  Provider sending another consumer mass communication without uuid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${bool[0]}  ${msg}    ${fileswithcaption}   
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${ENTER_UUID}"

JD-TC-ConsumerMassCommunication-UH3
    [Documentation]  Provider sending another consumer mass communication with invalid uuid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_uuid}=   Random Int  min=222   max=555


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME_B}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}  ${msg}    ${fileswithcaption}    ${invalid_uuid}    ${wid2}
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}  ${invalid_uuid}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    {'${invalid_uuid}': 'invalid uuid'}

JD-TC-ConsumerMassCommunication-UH4
    [Documentation]  Provider sending another consumer mass communication with another provider uuid
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME15}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${bool[0]}  ${msg}    ${fileswithcaption}     ${wid1}
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}  ${wid2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}    ${NO_PERMISSION}

JD-TC-ConsumerMassCommunication -UH5
    [Documentation]   Provider setting consumer mass communication without login  

    # ${cookie}   ${resp}=    Imageupload.spLogin    ${PUSERNAME_B}     ${PASSWORD}
    # Log     ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    
    ${resp}=  Consumer Mass Communication   ${EMPTY}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${bool[0]}  ${msg}    ${fileswithcaption}     ${wid2}
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}  ${wid2}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-ConsumerMassCommunication -UH6
    [Documentation]   Consumer doing mass communication
    ${resp}=   Consumer Login  ${CUSERPH0}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}   ${resp}=    Imageupload.conLogin     ${CUSERPH0}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    ${fileswithcaption}=  Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}
    ${msg}=  FakerLibrary.text
    
    ${resp}=  Consumer Mass Communication   ${cookie}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${bool[0]}  ${msg}    ${fileswithcaption}     ${wid2}
    # ${resp}=  Consumer Mass Communication  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${msg}  ${wid2}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"