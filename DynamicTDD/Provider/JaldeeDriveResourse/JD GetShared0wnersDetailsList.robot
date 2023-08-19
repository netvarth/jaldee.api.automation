***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           OperatingSystem
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Library           /ebs/TDD/db.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Resource          /ebs/TDD/Keywords.robot
Variables         /ebs/TDD/varfiles/consumermail.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/SuperAdminKeywords.robot




*** Variables ***
@{countryCode}   91  +91  48 
${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf
${SERVICE1}  Consultation 
${SERVICE2}  Scanning
${SERVICE3}  Scannings111
${SERVICE4}  CHECKING
@{service_duration}  10  20  30   40   50
${giffile}     /ebs/TDD/sample.gif
${jpegfile}     /ebs/TDD/large.jpeg
${bmpfile}     /ebs/TDD/first.bmp
${shfile}     /ebs/TDD/example.sh
${docfile}     /ebs/TDD/docsample.doc
${txtfile}     /ebs/TDD/textsample.txt
${digits}       0123456789
@{EMPTY_List} 
@{person_ahead}   0  1  2  3  4  5  6
${self}         0
@{service_duration}   5   20
${parallel}     1
${xlFile}      ${EXECDIR}/TDD/sampleqnr.xlsx    # DataSheet
${mp4file}   /ebs/TDD/MP4file.mp4
${mp4mime}   video/mp4
${mp3file}   /ebs/TDD/MP3file.mp3
${mp3mime}   audio/mpeg
${folderName}    private


***Test Cases***

JD-TC-GetSharedOnwnersDetailsList-1

    [Documentation]  Get pdf file details list - general communication
    
    clear_customer      ${PUSERNAME14}
 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME14}
    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME14}
    Set Test Variable  ${id}
 
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jcon_id}=  get_id  ${CUSERNAME2}
    clear_Consumermsg  ${CUSERNAME2}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

   
    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pdffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
   
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME14}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=  Get provider communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

   
    
    ${resp}=   Get List Of Shared 0wners   ${ownerType[1]}          ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings          ${resp.status_code}                     200
    Should Be Equal As Strings          ${resp.json()[0]['fileSize']}           0.003
    Should Be Equal As Strings          ${resp.json()[0]['fileType']}           pdf
    Should Be Equal As Strings          ${resp.json()[0]['account']}            ${acc_id}
    Should Be Equal As Strings          ${resp.json()[0]['sharedType']}         ${sharedType[1]}



JD-TC-GetSharedOnwnersDetailsList-2

    [Documentation]  Get  jpg file details list

    clear_Providermsg  ${PUSERNAME14}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME14}
    ${acc_id}=  get_acc_id  ${PUSERNAME14}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME14}
    Set Test Variable  ${id}
    
  
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${jc_id1}=  get_id  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}
    clear_Providermsg  ${PUSERNAME14}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpgfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
  
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME14}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}        ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                    200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}        0.223
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}       jpg
    Should Be Equal As Strings     ${resp.json()[0]['account']}        ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}       jpg
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}      ${ownerType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}        ${context[0]}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}      ${ownerType[1]}
  

JD-TC-GetSharedOnwnersDetailsList-3

    [Documentation]  Get png file details list
    
    ${resp}=  Encrypted Provider Login   ${PUSERNAME30}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     #Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME14}${\n}
    Set Test Variable   ${PUSERNAME30}
    ${acc_id}=  get_acc_id  ${PUSERNAME30}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME30}
    Set Test Variable  ${id}
     
    clear_Providermsg  ${PUSERNAME30}
  
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME5}
    clear_Consumermsg  ${CUSERNAME5}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME5}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${pngfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME30}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}        ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                      200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}     	 0.171 
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}         png
    Should Be Equal As Strings     ${resp.json()[0]['account']}          ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}        ${ownerType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}          ${context[0]}
    Should Be Equal As Strings     ${resp.json()[0]['sharedType']}       ${sharedType[1]}
  


JD-TC-GetSharedOnwnersDetailsList-4

    [Documentation]  Get jpeg file details list

    clear_Providermsg  ${PUSERNAME177}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME177}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME177}
    ${acc_id}=  get_acc_id  ${PUSERNAME177}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME177}
    Set Test Variable  ${id}
      
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME9}
    clear_Consumermsg  ${CUSERNAME9}
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME9}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${jpegfile} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
 
    ${resp}=   Encrypted Provider Login     ${PUSERNAME177}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ProviderConsumer        ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}     	0.798
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}        jpeg
    Should Be Equal As Strings     ${resp.json()[0]['account']}         ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}       ${ownerType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}         ${context[0]}
    Should Be Equal As Strings     ${resp.json()[0]['sharedType']}      ${sharedType[1]}
  


JD-TC-GetSharedOnwnersDetailsList-5

    [Documentation]  Get gif file details list

    ${resp}=   Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME187}
    ${acc_id}=  get_acc_id  ${PUSERNAME187}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME187}
    Set Test Variable  ${id}
     
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME8}
    clear_Consumermsg  ${CUSERNAME8}
   

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME8}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}  ${giffile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME187}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}       ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}      gif
    Should Be Equal As Strings     ${resp.json()[0]['account']}       ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}     ${ownerType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}       ${context[0]}
    Should Be Equal As Strings     ${resp.json()[0]['sharedType']}    ${sharedType[1]}
  


JD-TC-GetSharedOnwnersDetailsList-6

    [Documentation]  Get doc file details list

    clear_Providermsg  ${PUSERNAME102}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME102}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME102}
    ${acc_id}=  get_acc_id  ${PUSERNAME102}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME102}
    Set Test Variable  ${id}
     
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME11}
    clear_Consumermsg  ${CUSERNAME11}
   
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}    ${docfile}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME102}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}            ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}        doc
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}     	0.096
    Should Be Equal As Strings     ${resp.json()[0]['account']}         ${acc_id}
   


JD-TC-GetSharedOnwnersDetailsList-7

    [Documentation]  Get txt file details list

    clear_Providermsg  ${PUSERNAME167}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${PUSERNAME167}
    ${acc_id}=  get_acc_id  ${PUSERNAME167}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME167}
    Set Test Variable  ${id}
    
     
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME11}
    clear_Consumermsg  ${CUSERNAME11}
   # clear_Consumermsg  ${CUSERNAME3}
    clear_Providermsg  ${PUSERNAME167}


    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
      ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}   ${txtfile}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${c_id}
    Should Be Equal As Strings  ${resp.json()[0]['msg']}    ${msg}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['accountId']}    ${acc_id}
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME167}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}            ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}      0.001
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}     txt
    Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}    ${ownerType[1]}

JD-TC-GetSharedOnwnersDetailsList-8

    [Documentation]  get appointment attachment as jpg file 

    ${resp}=  Consumer Login  ${CUSERNAME8}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${jdconID}   ${resp.json()['id']}
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    ${c_id}=  get_id  ${CUSERNAME8}
    clear_Consumermsg  ${CUSERNAME8}
 
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME110}
     Set Test Variable   ${acc_id}
     
    
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME110}
    clear_location  ${PUSERNAME110}
    clear_customer   ${PUSERNAME110}

    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]}  

    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
     Set Suite Variable   ${s_id1}
   
    clear_appt_schedule   ${PUSERNAME8}

    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
  
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
  
    ${resp}=  AddCustomer  ${CUSERNAME8}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

   
    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME110}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}              200
    Should Be Equal As Strings     ${resp.json()[0]['fileSize']}    0.008
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    jpg
    Should Be Equal As Strings     ${resp.json()[0]['account']}     ${acc_id}
  
 

JD-TC-GetSharedOnwnersDetailsList-9

    [Documentation]   Get appointment attachment as pdf file.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME181}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id}=  get_acc_id  ${PUSERNAME181}
    Set Test Variable   ${acc_id}
    
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME181}
    clear_location  ${PUSERNAME181}
    clear_customer   ${PUSERNAME181}
    clear_appt_schedule   ${PUSERNAME181}

    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
   
   
    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
   
    ${resp}=  AddCustomer  ${CUSERNAME14}  #firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    
    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME181}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}   ${pdffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Appointment Attachment   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME14}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}     	0.003 
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}       pdf
    Should Be Equal As Strings     ${resp.json()[0]['account']}        ${acc_id}
  
     

JD-TC-GetSharedOnwnersDetailsList-10

    [Documentation]   Get appointment attachment as png file.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${acc_id}=  get_acc_id  ${PUSERNAME130}
    Set Test Variable   ${acc_id}
    
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME130}
    clear_location  ${PUSERNAME130}
    clear_customer   ${PUSERNAME130}
    clear_appt_schedule   ${PUSERNAME130}

    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
    
    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    
    ${resp}=  AddCustomer  ${CUSERNAME10}  #firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
      
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME130}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}   ${pngfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Appointment Attachment   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .png
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .png
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    0.171
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    png
    Should Be Equal As Strings     ${resp.json()[0]['account']}    ${acc_id}
  

JD-TC-GetSharedOnwnersDetailsList-11

    [Documentation]   get appointment attachment as jpeg file.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_service   ${PUSERNAME130}
    clear_location  ${PUSERNAME130}
    clear_customer   ${PUSERNAME130}
    ${acc_id}=  get_acc_id  ${PUSERNAME130}
    Set Test Variable   ${acc_id}
     
   
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME130}
    clear_location  ${PUSERNAME130}
    clear_customer   ${PUSERNAME130}
    clear_appt_schedule   ${PUSERNAME130}

    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
   
   
    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

   
    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    ${resp}=  AddCustomer  ${CUSERNAME10}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME130}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}   ${jpegfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Appointment Attachment   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}         0.798 
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}        jpeg
    Should Be Equal As Strings     ${resp.json()[0]['account']}         ${acc_id}
  
  
JD-TC-GetSharedOnwnersDetailsList-12

    [Documentation]   get appointment attachment as gif file.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME130}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${acc_id}=  get_acc_id  ${PUSERNAME130}
    Set Test Variable   ${acc_id}
     
    ${resp}=   Get Appointment Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableAppt']}==${bool[0]}   Enable Appointment

    clear_service   ${PUSERNAME130}
    clear_location  ${PUSERNAME130}
    clear_customer   ${PUSERNAME130}
    clear_appt_schedule   ${PUSERNAME130}

    ${lid}=  Create Sample Location 
    Set Suite Variable   ${lid}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
   
    ${s_id}=  Create Sample Service  ${SERVICE1}
    Set Suite Variable   ${s_id}
   
    ${s_id1}=  Create Sample Service  ${SERVICE2}
    Set Suite Variable   ${s_id1}
   
   
    ${resp}=  Create Sample Schedule  ${lid}   ${s_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response  ${resp}  id=${sch_id}      batchEnable=${bool[0]}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}
    
    
    ${resp}=  AddCustomer  ${CUSERNAME10}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}   ${resp.json()}
    
    ${apptfor1}=  Create Dictionary  id=${cid}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid}  ${s_id}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
          
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME130}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PApptAttachment   ${cookie}   ${apptid1}   ${caption}   ${giffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Appointment Attachment   ${apptid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

   
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
 
    
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                         200
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}     	   	1.009
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}            gif
    Should Be Equal As Strings     ${resp.json()[0]['account']}             ${acc_id} 
  


JD-TC-GetSharedOnwnersDetailsList-13

    [Documentation]   Provider get to upload Catalog image details

    clear_Item  ${PUSERNAME42}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${acc_id}=  get_acc_id  ${PUSERNAME42}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME42}
    Set Suite Variable  ${id}
       
    ${displayName1}=   FakerLibrary.name 
    Set Test Variable  ${displayName1}  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Test Variable  ${shortDesc1}   
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Test Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300 
    Set Test Variable  ${price1}
    ${price1float}=  twodigitfloat  ${price1}
    Set Test Variable  ${price1float}
    ${price2float}=   Convert To Number   ${price1}  2
    Set Test Variable  ${price2float}    
    ${itemName1}=   FakerLibrary.name
    Set Test Variable  ${itemName1}   
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Test Variable  ${itemNameInLocal1}    
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Test Variable  ${promoPrice1}
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Test Variable  ${promoPrice1float}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Test Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Test Variable   ${note1}    
    ${itemCode1}=   FakerLibrary.word 
    Set Test Variable  ${itemCode1}  
    ${promoLabel1}=   FakerLibrary.word 
    Set Test Variable  ${promoLabel1}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Pid1}  ${resp.json()}

    
    ${startDate}=  db.get_date_by_timezone  ${tz}
    Set Test Variable  ${startDate}
    ${endDate}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${endDate}

    # ${noOfOccurance}=  Random Int  min=0   max=10
    # Set Suite Variable  ${noOfOccurance}

    Set Suite Variable  ${noOfOccurance}   0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Test Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  0  30  
    Set Test Variable   ${eTime1}

    ${list}=  Create List  1  2  3  4  5  6  7
    Set Test Variable  ${list}

    ${deliveryCharge}=  Random Int  min=1   max=100
    Set Suite Variable  ${deliveryCharge}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    Set Test Variable  ${Title} 
    ${Text}=  FakerLibrary.Sentence   nb_words=4
    Set Test Variable  ${Text}

    ${minQuantity}=  Random Int  min=1   max=30
    Set Suite Variable  ${minQuantity}

    ${maxQuantity}=  Random Int  min=${minQuantity}   max=50
    Set Suite Variable  ${maxQuantity}

    ${catalogName}=   FakerLibrary.name 
    Set Suite Variable  ${catalogName} 

    ${catalogDesc}=   FakerLibrary.name 
    Set Suite Variable  ${catalogDesc} 

    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Suite Variable  ${cancelationPolicy} 


    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Test Variable  ${catalogSchedule}
    # -----------------------
    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${catalogSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Test Variable  ${pickUp}
    # -----------------------
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${catalogSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge}
    Set Test Variable  ${homeDelivery}
    # -----------------------
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Test Variable  ${preInfo}
    # -----------------------
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Test Variable  ${postInfo}
    # -----------------------
    ${orderStatuses}=  Create List  ${orderStatuses[0]}  ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Test Variable  ${orderStatuses}
    # -----------------------
    ${itemId1}=  Create Dictionary  itemId=${Pid1}
    ${Item1_list}=  Create Dictionary  item=${itemId1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    ${catalogItem}=  Create List   ${Item1_list}
    Set Test Variable  ${catalogItem}
    # -----------------------
    

    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=1   max=1000
    Set Test Variable  ${advanceAmount}

    ${far}=  Random Int  min=1   max=1000
    Set Test Variable  ${far}

    ${soon}=  Random Int  min=1   max=1000
    Set Test Variable  ${soon}

    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5


    ${resp}=  Create Catalog For ShoppingCart   ${catalogName}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${orderStatuses}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME42}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadCatalogImages   ${CatalogId1}   ${boolean[1]}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME42}  ${PASSWORD}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Be Equal As Strings  ${resp.json()['catalogImages']}   ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['catalogImages'][0]['displayImage']}   ${bool[1]}

  
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}           ${id}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}                        200
    Should Be Equal As Strings     ${resp.json()[0]['account']}               ${acc_id} 
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}             Provider
    Should Be Equal As Strings     ${resp.json()[0]['owner']}                 ${id} 
    Should Be Equal As Strings     ${resp.json()[0]['context']}               ${context[5]} 
    
  

JD-TC-GetSharedOnwnersDetailsList-14

    [Documentation]   Provider get to upload item image when displayImage is true

    clear_Item  ${PUSERNAME73}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${acc_id}=  get_acc_id  ${PUSERNAME73}
    Set Test Variable   ${acc_id}
     
    ${id1}=  get_id  ${PUSERNAME73}
    Set Suite Variable  ${id1}
     
    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Test Variable  ${shortDesc1}   
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Test Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300 
    Set Test Variable  ${price1}
    ${price1float}=  twodigitfloat  ${price1}
    Set Test Variable  ${price1float}
    ${price2float}=   Convert To Number   ${price1}  2
    Set Test Variable  ${price2float}    
    ${itemName1}=   FakerLibrary.name
    Set Test Variable  ${itemName1}   
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Test Variable  ${itemNameInLocal1}    
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Test Variable  ${promoPrice1}
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Test Variable  ${promoPrice1float}
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Test Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Test Variable  ${note1}    
    ${itemCode1}=   FakerLibrary.word 
    Set Test Variable  ${itemCode1}  
    ${promoLabel1}=   FakerLibrary.word 
    Set Test Variable  ${promoLabel1}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id}  ${resp.json()}

   
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   ${id}   ${boolean[1]}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    ${resp}=   Get Item By Id   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[1]}    
    # Should Contain  ${resp.json()['itemImages']}  /item/${id}/ 

    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}           ${id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['owner']}     	   	      ${id1}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}              png
    Should Be Equal As Strings     ${resp.json()[0]['account']}               ${acc_id} 
    Should Be Equal As Strings     ${resp.json()[0]['sharedType']}            ${sharedType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}             ${ownerType[0]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}               ${context[6]} 
   
  

  

JD-TC-GetSharedOnwnersDetailsList-15

    [Documentation]    Get file an order By Provider for pickup (Both ShoppingCart and ShoppingList).
    
    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    Set Test Variable  ${c15_Uid}     ${resp.json()['id']}
    Set Test Variable  ${c15_UName}   ${resp.json()['userName']}
    clear_Consumermsg  ${CUSERNAME29}
    clear_Providermsg  ${PUSERNAME127}
    clear_queue    ${PUSERNAME127}
    clear_service  ${PUSERNAME127}
    clear_customer   ${PUSERNAME127}
    clear_Item   ${PUSERNAME127}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME127}
    Set Test Variable  ${accId3} 
    ${id}=  get_id  ${PUSERNAME127}
    Set Suite Variable  ${id}
   

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME127}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

     ${resp}=   Get jaldeeIntegration Settings

     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}


     ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
     Should Be Equal As Strings  ${resp.status_code}  200
    
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${displayName3}=   FakerLibrary.name 
    Set Test Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Test Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Test Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Test Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Test Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Test Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id4}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Test Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    Set Test Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  1  05  
    Set Test Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  15   
    Set Test Variable    ${eTime2}


    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    Set Test Variable    ${deliveryCharge}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Test Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Test Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Test Variable   ${maxQuantity3}

    Log List  ${orderStatuses}
    ${catalogDesc}=   FakerLibrary.name 
    Set Test Variable  ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Test Variable  ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Test Variable  ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Test Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Test Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Test Variable  ${homeDelivery}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Test Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Test Variable  ${postInfo}
    #${list}=   List  ${orderStatuses[0]}   ${orderStatuses[1]}    ${orderStatuses[2]}
     ${StatusList1}=  Create List   ${orderStatuses[0]}   ${orderStatuses[1]}    ${orderStatuses[2]}    ${orderStatuses[3]}   ${orderStatuses[9]}    ${orderStatuses[8]}    ${orderStatuses[11]}     ${orderStatuses[12]}
    Set Test Variable  ${StatusList1} 
   # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Test Variable  ${catalogItem}
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}    ${catalogStatus[0]}
    Set Test Variable  ${paymentType}      ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Test Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${soon}
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Test Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Test Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    

    ${resp}=  AddCustomer  ${CUSERNAME29}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid18}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    Set Test Variable  ${DAY1}
    ${DATE12}=  Convert Date  ${DAY1}  result_format=%a, %d %b %Y
    Set Test Variable  ${DATE12}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME29}.ynwtest@netvarth.com

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid11}  ${orderid[0]}

    ${item_quantity1}=  FakerLibrary.Random Int  min=${minQuantity3}   max=${maxQuantity3}
    ${item_quantity1}=  Convert To Number  ${item_quantity1}  1
    Set Test Variable  ${item_quantity1}

    ${orderNote}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${orderNote}

    ${resp}=   Create Order By Provider For Pickup    ${cookie}  ${cid15}   ${cid15}   ${CatalogId2}   ${boolean[1]}    ${sTime1}    ${eTime1}   ${DAY1}    ${CUSERNAME20}    ${email}  ${orderNote}  ${countryCodes[1]}  ${item_id3}   ${item_quantity1}  ${item_id4}   ${item_quantity1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid12}  ${orderid[0]}

     



    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Order By Id  ${accId3}  ${orderid11}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no11}  ${resp.json()['orderNumber']}

    ${resp}=   Get Order By Id  ${accId3}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${order_no12}  ${resp.json()['orderNumber']}

    # --------------------------------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUSERNAME127}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}   ${resp}=    Imageupload.spLogin     ${PUSERNAME127}     ${PASSWORD}
    Log     ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${caption1}=  Fakerlibrary.Sentence
    ${filecap_dict1}=  Create Dictionary   file=${jpgfile}   caption=${caption1}
    ${caption2}=  Fakerlibrary.Sentence
    ${filecap_dict2}=  Create Dictionary   file=${pngfile}   caption=${caption2}
    ${caption3}=  Fakerlibrary.Sentence
    ${filecap_dict3}=  Create Dictionary   file=${pdffile}   caption=${caption3}
    @{fileswithcaption}=    Create List   ${filecap_dict1}   ${filecap_dict2}  ${filecap_dict3}

    ${msg1}=  FakerLibrary.text
    ${resp}=  Order Mass Communication    ${cookie}    ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[1]}   ${msg1}    ${fileswithcaption}   ${orderid11}  ${orderid12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Appointment Messages
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${Order_Message}=  Set Variable   ${resp.json()['orderMessages']['massCommunication']['Consumer_APP']} 
    Log  ${Order_Message}

    ${Order_Msg}=  Replace String  ${Order_Message}  [type]   ${msg_type[0]}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [consumer]   ${c15_UName}
    ${Order_Msg}=  Replace String  ${Order_Msg}  [message]   ${msg1}



    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}          ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['context']}         ${context[7]} 
  
   

  

JD-TC-GetSharedOnwnersDetailsList-16

    [Documentation]  get image  order By Provider for pickup.

    ${resp}=  Consumer Login  ${CUSERNAME32}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}
    
    clear_queue    ${PUSERNAME73}
    clear_service  ${PUSERNAME73}
    clear_customer   ${PUSERNAME73}
    clear_Item   ${PUSERNAME73}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${pid}  ${resp.json()['id']}

    Set Test Variable  ${pid1}  ${resp.json()['id']}
    
    ${accId3}=  get_acc_id  ${PUSERNAME73}
    Set Test Variable  ${accId3} 
     ${id}=  get_id  ${PUSERNAME73}
    Set Suite Variable  ${id}
   

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${email_id}  ${firstname}${PUSERNAME73}.ynwtest@netvarth.com

    ${resp}=  Update Email   ${pid1}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  Get Order Settings by account id
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['enableOrder']}==${bool[0]}   Enable Order Settings

     ${resp}=   Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[0]}    Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
     Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[3]}  ${GST_num} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    
    ${displayName3}=   FakerLibrary.name 
    Set Test Variable  ${displayName3}
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2  
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3   
    ${price2}=  Random Int  min=50   max=300 
    ${price2}=  Convert To Number  ${price2}  1
    Set Test Variable  ${price2}

    ${price1float}=  twodigitfloat  ${price2}

    ${itemName3}=   FakerLibrary.name  
    Set Test Variable  ${itemName3}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2  
  
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2}=  Convert To Number  ${promoPrice2}  1
    Set Test Variable  ${promoPrice2}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice2}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}

    ${note1}=  FakerLibrary.Sentence   

    ${itemCode3}=   FakerLibrary.word 

    ${itemCode4}=   FakerLibrary.word 

    ${promoLabel1}=   FakerLibrary.word 

    ${resp}=  Create Order Item    ${displayName3}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[0]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id3}  ${resp.json()}

    ${displayName4}=   FakerLibrary.name 
    Set Test Variable  ${displayName4}

    ${itemName4}=   FakerLibrary.name  
    Set Test Variable  ${itemName4}

    ${resp}=  Create Order Item    ${displayName4}    ${shortDesc1}    ${itemDesc1}    ${price2}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_id4}  ${resp.json()}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15        

    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Test Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00   
    Set Test Variable    ${eTime1}

    ${sTime2}=  add_timezone_time  ${tz}  1  05  
    Set Test Variable   ${sTime2}
    ${eTime2}=  add_timezone_time  ${tz}  2  15   
    Set Test Variable    ${eTime2}


    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    Set Test Variable    ${deliveryCharge}
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
    Set Test Variable    ${deliveryCharge3}

    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    Set Test Variable   ${minQuantity3}

    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50
    Set Test Variable   ${maxQuantity3}


    ${catalogDesc}=   FakerLibrary.name 
    Set Test Variable  ${catalogDesc}
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    Set Test Variable  ${cancelationPolicy}
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    Set Test Variable  ${terminator}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    Set Test Variable  ${terminator1}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime1}   eTime=${eTime1}
    ${timeSlots2}=  Create Dictionary  sTime=${sTime2}   eTime=${eTime2}
    ${timeSlots}=  Create List  ${timeSlots1}   ${timeSlots2}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    Set Test Variable  ${catalogSchedule}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    Set Test Variable  ${pickUp}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
    Set Test Variable  ${homeDelivery}
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    Set Test Variable  ${preInfo}
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    Set Test Variable  ${postInfo}
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}     ${orderStatuses[11]}   ${orderStatuses[12]}
    Set Test Variable  ${StatusList1} 
    # ${catalogItem1}=  Create Dictionary  itemId=${item_id1}    minQuantity=${minQuantity}   maxQuantity=${maxQuantity}  
    # ${catalogItem}=  Create List   ${catalogItem1}
    
    ${item1_Id}=  Create Dictionary  itemId=${item_id3}
    ${item2_Id}=  Create Dictionary  itemId=${item_id4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}
    Set Test Variable  ${catalogItem}
    Set Test Variable  ${orderType1}       ${OrderTypes[0]}
    Set Test Variable  ${orderType2}       ${OrderTypes[1]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}

    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    Set Test Variable  ${far}
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${soon}
    Set Test Variable  ${minNumberItem}   1

    Set Test Variable  ${maxNumberItem}   5

    ${catalogName1}=   FakerLibrary.word 
    Set Test Variable  ${catalogName1}

    ${catalogName2}=   FakerLibrary.name 
    Set Test Variable  ${catalogName2}

    ${resp}=  Create Catalog For ShoppingList   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType2}   ${paymentType}   ${StatusList1}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName2}  ${catalogDesc}   ${catalogSchedule}   ${orderType1}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId2}   ${resp.json()}


    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  AddCustomer  ${CUSERNAME32}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid15}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME32}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME18}  firstName=${fname}   lastName=${lname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid18}   ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    
    ${DAY1}=  db.add_timezone_date  ${tz}  12  
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${email}  ${firstname}${CUSERNAME32}.ynwtest@netvarth.com

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  FakerLibrary.Sentence   nb_words=4

                                               
    ${resp}=   Upload ShoppingList By Provider for Pickup    ${cookie}   ${cid15}   ${caption}   ${cid15}    ${CatalogId1}   ${bool[1]}   ${DAY1}    ${sTime1}    ${eTime1}    ${CUSERNAME19}    ${email} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${orderid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${orderid1}  ${orderid[0]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME73}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}           ${id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['context']}               ${context[6]} 
  
   



JD-TC-GetSharedOnwnersDetailsList-17

    [Documentation]   Get waitlist attachment as jpg file.

    clear_queue      ${PUSERNAME79}
    clear_location   ${PUSERNAME79}
    clear_service    ${PUSERNAME79}
    clear_customer   ${PUSERNAME79}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable   ${PUSERNAME79}
    ${acc_id}=  get_acc_id  ${PUSERNAME79}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME79}
    Set Test Variable  ${id}
     
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${SERVICE1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME79}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid1}   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Waitlist Attachment   ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}        ${cid}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    jpg
    Should Be Equal As Strings     ${resp.json()[0]['account']}     ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}   ${ownerType[1]}
    Should Be Equal As Strings     ${resp.json()[0]['context']}     ${context[8]} 
  
   
   


JD-TC-GetSharedOnwnersDetailsList-18

    [Documentation]   Get waitlist attachment as doc file.

    clear_queue      ${PUSERNAME79}
    clear_location   ${PUSERNAME79}
    clear_service    ${PUSERNAME79}
    clear_customer   ${PUSERNAME79}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Test Variable   ${PUSERNAME79}
    ${acc_id}=  get_acc_id  ${PUSERNAME79}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME79}
    Set Test Variable  ${id}
     

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${SERVICE1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME79}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid1}   ${caption}    ${docfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}        ${cid}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    doc
    Should Be Equal As Strings     ${resp.json()[0]['account']}     ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}   ${ownerType[1]}
   
  
    
JD-TC-GetSharedOnwnersDetailsList-19

    [Documentation]   Get waitlist attachment as pdf file.

    clear_queue      ${PUSERNAME79}
    clear_location   ${PUSERNAME79}
    clear_service    ${PUSERNAME79}
    clear_customer   ${PUSERNAME79}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${acc_id}=  get_acc_id  ${PUSERNAME79}
    Set Test Variable   ${acc_id} 


    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${SERVICE1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME79}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid1}   ${caption}    ${pdffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Waitlist Attachment   ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .pdf
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 



    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
     Should Be Equal As Strings    ${resp.json()[0]['owner']}        ${cid}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}     pdf
    Should Be Equal As Strings     ${resp.json()[0]['account']}      ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}    ${ownerType[1]}
   
   



JD-TC-GetSharedOnwnersDetailsList-20

    [Documentation]   Get waitlist attachment as jpeg file.

    clear_queue      ${PUSERNAME79}
    clear_location   ${PUSERNAME79}
    clear_service    ${PUSERNAME79}
    clear_customer   ${PUSERNAME79}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${acc_id}=  get_acc_id  ${PUSERNAME79}
    Set Test Variable   ${acc_id} 

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${SERVICE1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME79}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid1}   ${caption}    ${jpegfile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Waitlist Attachment   ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpeg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 


    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}        ${cid}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    jpeg
    Should Be Equal As Strings     ${resp.json()[0]['account']}     ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}   ${ownerType[1]}
   
   

JD-TC-GetSharedOnwnersDetailsList-21

    [Documentation]   Get waitlist attachment as gif file.

    clear_queue      ${PUSERNAME79}
    clear_location   ${PUSERNAME79}
    clear_service    ${PUSERNAME79}
    clear_customer   ${PUSERNAME79}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200
    ${acc_id}=  get_acc_id  ${PUSERNAME79}
    Set Test Variable   ${acc_id} 

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   200

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer      ${PUSERNAME79} 
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    
    ${resp}=   Create Sample Location
    Set Test Variable    ${loc_id1}    ${resp}  

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz} 
    ${SERVICE1}=   FakerLibrary.word
    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id1}    ${resp}  
    ${q_name}=    FakerLibrary.word
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    ${parallel}=   Random Int  min=1   max=1
    ${capacity}=  Random Int   min=10   max=20
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME79}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.PWLAttachment   ${cookie}   ${wid1}   ${caption}    ${giffile}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Waitlist Attachment   ${wid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .gif
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 


    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}        ${cid}
    Should Be Equal As Strings     ${resp.json()[0]['fileType']}    gif
    Should Be Equal As Strings     ${resp.json()[0]['account']}     ${acc_id}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}   ${ownerType[1]}
   
   

JD-TC-GetSharedOnwnersDetailsList-22

    [Documentation]  Submit questionnaire for appointment
    
    ${resp}=  Consumer Login  ${CUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    ${c_id13}=  get_id  ${CUSERNAME13}
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${acc_id3}=  get_acc_id  ${PUSERNAME113}
    Set Test Variable   ${acc_id3} 

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[2]}'
            ${s_id12}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE IF  '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'
            ${d_id}=  Set Variable   ${resp.json()[${i}]['id']}
        ELSE
            Append To List  ${snames}  ${resp.json()[${i}]['name']}
        END
    END

    Log  ${snames}
    ${srv_val}=    Get Variable Value    ${s_id12}
    ${don_val}=    Get Variable Value    ${d_id}
    
    IF  '${srv_val}'=='${None}' or '${don_val}'=='${None}'
        ${snames_len}=  Get Length  ${unique_snames}
        FOR  ${i}  IN RANGE   ${snames_len}
            &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
            ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
            Log  ${ttype}
            ${u_ttype}=    Remove Duplicates    ${ttype}
            Log  ${u_ttype}
            IF   '${QnrTransactionType[3]}' in @{u_ttype} and '${srv_val}'=='${None}'
                ${s_id12}=  Create Sample Service  ${unique_snames[${i}]}  maxBookingsAllowed=10
            ELSE IF  '${QnrTransactionType[0]}' in @{u_ttype} and '${don_val}'=='${None}'
                ${d_id}=  Create Sample Donation  ${unique_snames[${i}]}
            END
        END
    END

    Set Suite Variable   ${s_id12}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  ${resp.json()['enableAppt']}==${bool[0]}   
        ${resp}=   Enable Appointment 
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=   Get Appointment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableAppt']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['enableToday']}   ${bool[1]} 

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}  

    clear_appt_schedule   ${PUSERNAME113}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    
    ${resp}=  Create Sample Schedule   ${lid}   ${s_id12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sch_id}  ${resp.json()}

    ${resp}=  Get Appointment Schedule ById  ${sch_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${sch_id}  apptState=${Qstate[0]}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
        IF  '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[3]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[0]}'
            ${id}   Set Variable  ${resp.json()[${i}]['id']}
            ${qnrid}   Set Variable  ${resp.json()[${i}]['questionnaireId']}
            Exit For Loop If   '${id}' != '${None}'
        END
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${s_id12}
    IF  '${qns.json()['status']}' == '${status[1]}' 
        ${resp1}=   Provider Change Questionnaire Status  ${id}  ${status[0]}  
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Get Appointment Slots By Date Schedule  ${sch_id}  ${DAY1}  ${s_id12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}    scheduleId=${sch_id}
    Set Test Variable   ${slot1}   ${resp.json()['availableSlots'][0]['time']}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME13}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME13}  firstName=${fname}   lastName=${lname}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid13}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid13}  ${resp.json()[0]['id']}
    END
    
    ${apptfor1}=  Create Dictionary  id=${cid13}   apptTime=${slot1}
    ${apptfor}=   Create List  ${apptfor1}
    
    ${cnote}=   FakerLibrary.word
    ${resp}=  Take Appointment For Consumer  ${cid13}  ${s_id12}  ${sch_id}  ${DAY1}  ${cnote}  ${apptfor}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${apptid}=  Get Dictionary Values  ${resp.json()}   sort_keys=False
    Set Test Variable  ${apptid1}  ${apptid[0]}

    # ${resp}=  Get Appointment EncodedID   ${apptid1}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${encId}=  Set Variable   ${resp.json()}

    ${resp}=  Get Appointment By Id   ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['uid']}   ${apptid1}

    ${resp}=  Get Questionnaire By uuid For Appmt    ${apptid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()[0]['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()[0]['id']}   ${id}
    
    ${fudata}=  db.fileUploadDT   ${resp.json()[0]}  ${FileAction[0]}  ${mp4file}  ${mp3file}
    Log  ${fudata}

    ${data}=  db.QuestionnaireAnswers   ${resp.json()[0]}   ${cid13}   &{fudata}
    Log  ${data}
    ${resp}=  Provider Validate Questionnaire  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME113}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.PApptQAnsUpload   ${cookie}  ${apptid1}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${resp}=  Get Appointment By Id   ${apptid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    #Check Answers   ${resp}  ${data}

    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}            ${c_id13}
    Log  ${resp.content}
    Should Be Equal As Strings     ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()[0]['owner']}          ${c_id13}
    Should Be Equal As Strings     ${resp.json()[0]['account']}        ${acc_id3}
    Should Be Equal As Strings     ${resp.json()[0]['ownerType']}      ${ownerType[1]} 
    Should Be Equal As Strings     ${resp.json()[0]['context']}        ${context[1]} 
   
   

JD-TC-GetSharedOnwnersDetailsList-23

    [Documentation]   Get waitlist attachment as jpg file done by consumer and get the attachment.
    
    clear_queue      ${PUSERNAME178}
    clear_location   ${PUSERNAME178}
    clear_service    ${PUSERNAME178}
    clear_customer   ${PUSERNAME178}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${acc_id}=  get_acc_id  ${PUSERNAME178}
    Set Test Variable   ${acc_id} 
    ${resp}=  AddCustomer  ${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid11}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME11}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
   
   
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=2
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${resp}=  Consumer Login  ${CUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${acc_id}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cnote}  ${bool[0]}  ${self} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${uuid}  ${wid[0]}   
    
    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[0]}

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME11}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cookie}
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.CWLAttachment   ${cookie}   ${acc_id}   ${uuid}   ${caption}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Waitlist Attachment   ${acc_id}   ${uuid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}            200
    Dictionary Should Contain Key  ${resp.json()[0]}   s3path
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Dictionary Should Contain Key  ${resp.json()[0]}   thumbPath
    Should Contain  ${resp.json()[0]['s3path']}   .jpg
    Should Be Equal As Strings  ${resp.json()[0]['caption']}     ${caption} 

    ${resp}=  Get consumer Waitlist By Id   ${uuid}  ${acc_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['hasAttachment']}    ${bool[1]}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME178}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}           ${cid11}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
   


JD-TC-GetSharedOnwnersDetailsList-UH1

    [Documentation]  Get upload file without provider login
  
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}        ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
 

JD-TC-GetSharedOnwnersDetailsList-UH2

    [Documentation]  Get upload  file by another provider login

    
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME13}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

   
    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}            ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()}      []
   

JD-TC-GetSharedOnwnersDetailsList-UH3

    [Documentation]  Get upload empty file by provider id

    clear_Providermsg  ${PUSERNAME107}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME107}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     #Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME14}${\n}
    Set Test Variable  ${PUSERNAME107}
    ${acc_id4}=  get_acc_id  ${PUSERNAME107}
    Set Test Variable   ${acc_id4}
    ${id}=  get_id  ${PUSERNAME107}
    Set Test Variable  ${id}
   
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${c_id}=  get_id  ${CUSERNAME10}
    clear_Consumermsg  ${CUSERNAME10}
 
    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME10}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg}=  Fakerlibrary.sentence
    ${caption}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithProvider   ${cookie}   ${acc_id4}  ${msg}  ${messageType[0]}  ${caption}  ${EMPTY}    ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
   
    ${resp}=  Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login     ${PUSERNAME107}   ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME10}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get List Of Shared 0wners     ${ownerType[1]}            ${c_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
    Should Be Equal As Strings     ${resp.json()}      []

JD-TC-GetSharedOnwnersDetailsList-UH4

    [Documentation]    consumer login
      
    ${resp}=   ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}        ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}    401
    Should Be Equal As Strings           ${resp.json()}         ${LOGIN_NO_ACCESS_FOR_URL}

JD-TC-GetSharedOnwnersDetailsList-UH5

    [Documentation]  invalid id pass

    clear_Providermsg  ${PUSERNAME167}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     #Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME14}${\n}
    Set Test Variable  ${PUSERNAME167}
    ${acc_id}=  get_acc_id  ${PUSERNAME167}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME167}
    Set Test Variable  ${id}
   
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}        000
    Log  ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}    200
    Should Be Equal As Strings           ${resp.json()}         []


JD-TC-GetSharedOnwnersDetailsList-UH6

    [Documentation]  empty id pass

    clear_Providermsg  ${PUSERNAME167}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
     #Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME14}${\n}
    Set Test Variable  ${PUSERNAME167}
    ${acc_id}=  get_acc_id  ${PUSERNAME167}
    Set Test Variable   ${acc_id}
    ${id}=  get_id  ${PUSERNAME167}
    Set Test Variable  ${id}
   
    ${resp}=   Get List Of Shared 0wners    ${ownerType[0]}        000
    Log  ${resp.content}
    Should Be Equal As Strings           ${resp.status_code}    200
    Should Be Equal As Strings           ${resp.json()}         []

    
JD-TC-GetSharedOnwnersDetailsList-24
   
    [Documentation]   get   Questionnaire Donation  file

    ${wb}=  readWorkbook  ${xlFile}
    ${sheet1}  GetCurrentSheet   ${wb}
    Set Suite Variable   ${sheet1}
    ${colnames}=  getColumnHeaders  ${sheet1}
    Log List  ${colnames}
    Log List  ${QnrChannel}
    Log List  ${QnrTransactionType}
    Set Suite Variable   ${colnames}
    ${servicenames}   getColumnValuesByName  ${sheet1}  ${colnames[6]}
    Log   ${servicenames}
    Set Suite Variable   ${servicenames}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Enable Disable Online Payment   ${toggle[0]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}
    ${lid}=   Create Sample Location
    Set Suite Variable    ${lid} 
    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ${id}=  get_id  ${PUSERNAME167}
    Set Suite Variable  ${id}
  
    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    @{snames}=  Create List
    FOR  ${i}  IN RANGE   ${s_len}
        Append To List  ${snames}  ${resp.json()[${i}]['name']}
    END

    Remove Values From List  ${servicenames}   ${NONE}
    Log  ${servicenames}
    ${unique_snames}=    Remove Duplicates    ${servicenames}
    Log  ${unique_snames}
    Set Suite Variable   ${unique_snames}
    ${snames_len}=  Get Length  ${unique_snames}
    FOR  ${i}  IN RANGE   ${snames_len}
        ${kwstatus} 	${value} = 	Run Keyword And Ignore Error  List Should Contain Value  ${snames}  ${unique_snames[${i}]}
        Log Many  ${kwstatus} 	${value}
        Continue For Loop If  '${kwstatus}' == 'PASS'
        &{dict}=  Create Dictionary   ${colnames[6]}=${unique_snames[${i}]}
        ${ttype}=  getColumnValueByMultipleVals  ${sheet1}  ${colnames[1]}  &{dict}  
        Log  ${ttype}
        ${u_ttype}=    Remove Duplicates    ${ttype}
        Log  ${u_ttype}
        ${s_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[3]}' in @{u_ttype}  Create Sample Service  ${unique_snames[${i}]}
        ${d_id}=  Run Keyword If   '${kwstatus}' == 'FAIL' and '${QnrTransactionType[0]}' in @{u_ttype}   Create Sample Donation  ${unique_snames[${i}]}
    END

    ${resp}=  AddCustomer  ${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid12}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
 


    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${cookie}  ${resp}=  Imageupload.SALogin    ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.UploadQuestionnaire   ${cookie}   ${account_id}   ${xlFile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME167}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}  

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=   Get Service
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${s_len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${s_len}
        ${d_id}=  Run Keyword If   '${resp.json()[${i}]['name']}' in @{unique_snames} and '${resp.json()[${i}]['serviceType']}' == '${service_type[0]}'   Set Variable   ${resp.json()[${i}]['id']}
        Exit For Loop If   '${d_id}' != '${None}'
    END
    Set Suite Variable   ${d_id}

    ${resp}=  Get Questionnaire List By Provider   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${len}=  Get Length  ${resp.json()}
    FOR  ${i}  IN RANGE   ${len}
      ${id}  Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['id']} 
      ${qnrid}   Run Keyword If   '${resp.json()[${i}]['transactionType']}' == '${QnrTransactionType[0]}' and '${resp.json()[${i}]['channel']}' == '${QnrChannel[1]}' and '${resp.json()[${i}]['captureTime']}' == '${QnrcaptureTime[0]}'  Set Variable  ${resp.json()[${i}]['questionnaireId']}
      Exit For Loop If   '${id}' != '${None}'
    END
    Set Suite Variable   ${id}
    Set Suite Variable   ${qnrid}

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings  ${qns.json()['transactionId']}  ${d_id}

    ${resp1}=  Run Keyword If   '${qns.json()['status']}' == '${status[1]}'  Provider Change Questionnaire Status  ${id}  ${status[0]}  
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${qns}   Get Provider Questionnaire By Id   ${id}  
    Log  ${qns.content}
    Should Be Equal As Strings  ${qns.status_code}  200
    Should Be Equal As Strings   ${qns.json()['status']}  ${status[0]}
    Set Suite Variable  ${Questionnaireid}  ${qns.json()['questionnaireId']}

    ${resp}=  Consumer Login  ${CUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}
    Set Suite Variable  ${con_id}   ${resp.json()['id']}

    ${don_amt}=   Random Int   min=500   max=1000  step=10
    ${don_amt}=  Convert To Number  ${don_amt}  1
    ${resp}=  Donation By Consumer  ${con_id}  ${d_id}  ${lid}  ${don_amt}  ${fname}  ${lname}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${don_id}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${don_id}  ${don_id[0]}

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}    uid=${don_id}

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    # Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

    ${fudata}=  db.fileUploadDT   ${resp.json()}  ${FileAction[0]}  ${Questionnaireid}  ${pdffile}
    Log  ${fudata}
    ${data}=  db.QuestionnaireAnswers   ${resp.json()}   ${self}   &{fudata}
    Log  ${data}
    Set Suite Variable   ${data}
    ${resp}=  Consumer Validate Questionnaire  ${account_id}  ${data}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.conLogin  ${CUSERNAME12}   ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings   ${resp.status_code}    200

    ${resp}=  Imageupload.CDonationQAnsUpload   ${cookie}  ${account_id}   ${don_id}   ${data}  ${pdffile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Consumer View Questionnaire  ${account_id}  ${d_id}  ${self}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Check Answers   ${resp}  ${data}

    ${resp}=   Get Donation Questionnaire By Id   ${account_id}  ${d_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings   ${resp.json()['questionnaireId']}  ${qnrid}
    Should Be Equal As Strings  ${resp.json()['id']}   ${id}

   

    ${resp}=  Get Consumer Donation By Id  ${don_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
   # Check Answers   ${resp}  ${data}
    ${resp}=   Consumer Logout         
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login   ${PUSERNAME167}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get List Of Shared 0wners    ${ownerType[1]}         ${cid12}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}                     200
   

