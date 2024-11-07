*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           random
Library           /ebs/TDD/CustomKeywords.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

${pngfile}     /ebs/TDD/upload.png
${pdffile}     /ebs/TDD/sample.pdf
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${jpgfile}      /ebs/TDD/uploadimage.jpg
${self}      0
@{service_names}
${order}        0
${fileSize}     0.00458


*** Keywords ***

Upload StatusBoard Logo
    [Arguments]  ${statusboard_id}   ${attachments}
    ${data}=  Create Dictionary   attachments=${attachments} 
    ${data}=  json.dumps  ${data}
    Check And Create YNW Session
    ${resp}=  POST On Session  ynw  /provider/appointment/statusBoard/logo/${statusboard_id}   data=${data}  expected_status=any
    Check Deprication  ${resp}  Create Status Board Appointment
    RETURN  ${resp}

*** Test Cases ***

JD-TC-UploadStatusboardLogo-1

    [Documentation]    Create a StatusBoard for Appointment using service id

    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME45}  ${PASSWORD} 
    Should Be Equal As Strings  ${resp.status_code}  200

    # clear_service   ${HLPUSERNAME45}
    # clear_location  ${HLPUSERNAME45}
    clear_Addon  ${HLPUSERNAME45}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Test Variable   ${lid}
        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${lid}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${DAY2}=  db.add_timezone_date  ${tz}  10    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${delta}=  FakerLibrary.Random Int  min=10  max=60
    ${eTime1}=  add_timezone_time  ${tz}  3   50  
   
    ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Append To List  ${service_names}  ${SERVICE1}   
    ${s_id}=  Create Sample Service  ${SERVICE1}      maxBookingsAllowed=20
    Set Test Variable  ${s_id}

    ${resp}=    Get Appointment Schedules
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'       
        ${schedule_name}=  FakerLibrary.bs
        ${parallel}=  FakerLibrary.Random Int  min=10  max=20
        ${maxval}=  Convert To Integer   ${delta/2}
        ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
        ${bool1}=  Random Element  ${bool}
        ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}  ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id}  
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${sch_id}  ${resp.json()}
    ELSE
        Set Test Variable  ${sch_id}  ${resp.json()[0]['id']}
        Set Test Variable  ${lid}  ${resp.json()[0]['location']['id']}
        Set Test Variable  ${s_id}  ${resp.json()[0]['services'][0]['id']}
    END
    
    ${Addon_id}=  get_statusboard_addonId
    ${resp}=  Add addon  ${Addon_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200  

    ${order1}=   Random Int   min=0   max=1
    ${Values}=  FakerLibrary.Words  	nb=3

    ${fieldList}=  Create Fieldlist For QueueSet  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${bool[0]}  ${order1}
    Log  ${fieldList}
    ${service_list}=  Create list  ${s_id}
    ${s_name}=  FakerLibrary.Words  nb=2
    ${s_desc}=  FakerLibrary.Sentence
    ${serr}=  Create Dictionary  id=${s_id}
    ${ser}=  Create List   ${serr} 
    ${dep}=  Create List   
    ${appt_sh}=   Create Dictionary  id=${sch_id}
    ${appt_shd}=    Create List   ${appt_sh}
    ${app_status}=    Create List   ${apptStatus[2]}
    ${resp}=  Create Appointment QueueSet for Provider   ${s_name[0]}  ${s_name[1]}   ${s_desc}   ${fieldList}   ${ser}     ${EMPTY}   ${EMPTY}    ${appt_shd}    ${app_status}         ${statusboard_type[0]}   ${service_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sba_id1}  ${resp.json()}

    ${Positions}=  FakerLibrary.Words  	nb=3
    ${matric_list}=  Create Metric For Status Board  ${Positions[0]}  ${sba_id1}  
    Log  ${matric_list}
    ${Data}=  FakerLibrary.Words  	nb=3
    Set Suite Variable  ${Data12}  ${Data}

    ${resp}=   Create Status Board Appointment    ${Data[0]}  ${Data[1]}  ${Data[2]}  ${matric_list}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sb_id}  ${resp.json()}

    ${resp}=  Get Appoinment StatusBoard By Id   ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  db.getType   ${pdffile}
    Log  ${resp}
    ${fileType1}=  Get From Dictionary       ${resp}    ${pdffile}
    ${caption1}=  Fakerlibrary.Sentence
    ${fileName}=    generate_filename
    
    ${attachments}=  Create Dictionary   fileName=${fileName}  

*** Comments ***
    ${resp}=  Upload StatusBoard Logo  ${sb_id}   ${attachments}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appoinment StatusBoard By Id   ${sb_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

