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
# ${CAUSERNAME}             admin.support@jaldee.com
# ${SPASSWORD}              Netvarth1
${PASSWORD}               Netvarth12
${NEWPASSWORD}            Jaldee12
${test_mail}              test@jaldee.com
${count}                  ${1}
${var_file}               ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${jpgfile}                /ebs/TDD/uploadimage.jpg
${order}                  0
${coverpic}               /ebs/TDD/coverpic.jpg
${coverimg}               /ebs/TDD/cover.jpg

*** Test Cases ***

JD-TC-Change Password-1
    [Documentation]  check basic functionalities of a provider
    
    Log  ${var_file}
    ${cust_pro}=  Evaluate  random.choice(list(open($var_file)))  random
    Log  ${cust_pro}
    ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    ${variable} 	${number}=   Split String    ${cust_pro}  =  
    Set Suite Variable  ${number}

    comment  change provider password.

    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Provider Change Password  ${PASSWORD}  ${NEWPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${number}  ${NEWPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment  change provider password back to old password.

    ${resp}=  Provider Change Password  ${NEWPASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment  Reset provider password.

    ${resp}=  SendProviderResetMail   ${number}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${number}  ${NEWPASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${number}  ${NEWPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    comment  change provider password back to old password.

    ${resp}=  Provider Change Password  ${NEWPASSWORD}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    comment  Upload business logo for provider

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${provider_id1}  ${decrypted_data['id']}

    ${fileSize}=  OperatingSystem.Get File Size  ${jpgfile}
    ${type}=  db.getType   ${jpgfile}
    # Log  ${type}
    ${fileType1}=  Get From Dictionary       ${type}    ${jpgfile}
    ${caption1}=  Fakerlibrary.Sentence
    ${path} 	${file} = 	Split String From Right 	${jpgfile} 	/ 	1
    ${fileName}  ${file_ext}= 	Split String 	${file}  .

    ${resp}=    Add Business Logo    ${provider_id1}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption1}    ${fileType1}    ${order}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Logo
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}              200
    Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id1}
    Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${{float('${fileSize}')}}
    # Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['action']}      ${FileAction[0]}


    ${cookie}  ${resp}=   Imageupload.spLogin  ${number}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=    Upload Cover Picture  ${cookie}  ${caption1}  ${coverpic}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${fileSize}=  OperatingSystem.Get File Size  ${coverpic}
    ${type}=  db.getType   ${coverpic}
    # Log  ${type}
    ${fileType1}=  Get From Dictionary       ${type}    ${coverpic}
    ${path} 	${file} = 	Split String From Right 	${coverpic} 	/ 	1
    ${fileName}  ${file_ext}= 	Split String 	${file}  .
    
    ${resp}=    Get Cover Picture
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings    ${resp.json()[0]['keyName']}       coverjpg
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['prefix']}    ${fileName}
    Should Be Equal As Strings    ${resp.json()[0]['type']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['originalName']}    ${coverpic}
    # Should Be Equal As Strings    ${resp.json()[0]['size']}    ${{float('${fileSize}')}}
    Should Be Equal As Strings    ${resp.json()[0]['contentLength']}      ${fileSize}