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
${data_file}              ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}phnumbers.txt
${jpgfile}                /ebs/TDD/images.jpeg
${order}                  0
# ${coverpic}               /ebs/TDD/coverpic.jpg
${coverimg}               /ebs/TDD/cover.jpg
${coverpic}               /ebs/TDD/banner.jpg
${logoimg}                /ebs/TDD/images1.jpeg
@{salutations}                  MR  MRS

*** Test Cases ***

JD-TC-Change Password-1
    [Documentation]  check basic functionalities of a provider
    
    Log Many  ${var_file}  ${data_file}
    ${cust_pro}=  Evaluate  random.choice(list(open($var_file)))  random
    Log  ${cust_pro}
    ${cust_pro}=   Set Variable  ${cust_pro.strip()}
    ${variable} 	${number}=   Split String    ${cust_pro}  =  
    Set Test Variable  ${number}

    comment  change provider password.

    ${resp}=  Encrypted Provider Login  ${number}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${createdDAY}  ${resp.json()['createdDate']}

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

    comment  change login id

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PUSERPH}  555${PH_Number}

    ${resp}=  Send Verify Login   ${PUSERPH}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Verify Login   ${PUSERPH}  ${OtpPurpose['ProviderVerifyEmail']}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200

    comment  change login id back to original number

    ${resp}=  Send Verify Login   ${number}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Verify Login   ${number}  ${OtpPurpose['ProviderVerifyEmail']}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Encrypted Provider Login  ${number}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${provider_id}  ${decrypted_data['id']}
    Set Test Variable  ${firstname}  ${decrypted_data['firstName']}
    Set Test Variable  ${lastname}  ${decrypted_data['lastName']}
    Set Test Variable   ${domain}  ${decrypted_data['sector']}
    Set Test Variable   ${subdomain}  ${decrypted_data['subSector']}
    Set Suite Variable    ${username}    ${decrypted_data['userName']}

    # ${resp}=  Get Locations
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${lid}  ${resp.json()[0]['id']}

    comment  update business profile
    
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${name3}=  FakerLibrary.word
    ${emails1}=  Emails  ${name3}  Email  ${number}${P_Email}.${test_mail}  ${views}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Test Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Update Business Profile without schedule   ${bs}  ${bs} Description   ${companySuffix}  ${city}  ${longi}  ${latti}  ${url}  free  True  ${postcode}  ${address}  ${EMPTY}  ${EMPTY}  ${emails1}  ${EMPTY}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  businessName=${bs}  businessDesc=${bs} Description  shortName=${companySuffix}  status=ACTIVE  createdDate=${createdDAY}  updatedDate=${DAY1}
    Should Be Equal As Strings  ${resp.json()['serviceSector']['domain']}  ${domain}
    Should Be Equal As Strings  ${resp.json()['serviceSubSector']['subDomain']}  ${subdomain}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['label']}  ${name3}
    Should Be Equal As Strings  ${resp.json()['emails'][0]['instance']}  ${number}${P_Email}.${test_mail}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
    # Should Be Equal As Strings  ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['place']}  ${city}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['address']}   ${address}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['pinCode']}  ${postcode}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['longitude']}  ${longi}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['lattitude']}  ${latti}
    Should Be Equal As Strings  ${resp.json()['baseLocation']['googleMapUrl']}  www.${bs}.com
    Should Be Equal As Strings  ${resp.json()['baseLocation']['parkingType']}  free
    Should Be Equal As Strings  ${resp.json()['baseLocation']['open24hours']}  True

    ${resp}=  Get Locations
    Should Be Equal As Strings  ${resp.status_code}  200

    ${fields}=   Get subDomain level Fields  ${domain}  ${subdomain}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${subdomain}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domain}  ${subdomain}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    comment  Upload business logo for provider

    ${fileSize}=  OperatingSystem.Get File Size  ${jpgfile}
    ${type}=  db.getType   ${jpgfile}
    # Log  ${type}
    ${fileType}=  Get From Dictionary       ${type}    ${jpgfile}
    ${caption}=  Fakerlibrary.Sentence
    ${path} 	${file} = 	Split String From Right 	${jpgfile} 	/ 	1
    ${fileName}  ${file_ext}= 	Split String 	${file}  .

    # ${resp}    upload file to temporary location    ${file_action[0]}    ${provider_id}    ${ownerType[0]}    ${username}    ${jpgfile}    ${fileSize}    ${caption}    ${fileType}    ${EMPTY}    ${order}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200 
    # Set Suite Variable    ${driveId}    ${resp.json()[0]['driveId']}

    # ${resp}    change status of the uploaded file    ${QnrStatus[1]}    ${driveId}
    # Log  ${resp.content}
    # Should Be Equal As Strings     ${resp.status_code}    200

    # ${resp}=    Add Business Logo    ${provider_id}    ${fileName}    ${fileSize}    ${FileAction[0]}    ${caption}    ${fileType}    ${order}  driveId=${driveId}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Business Logo
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}              200
    # Should Be Equal As Strings    ${resp.json()[0]['owner']}       ${provider_id}
    # Should Be Equal As Strings    ${resp.json()[0]['fileName']}    ${fileName}
    # Should Be Equal As Strings    ${resp.json()[0]['fileSize']}    ${{float('${fileSize}')}}
    # # Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    # Should Be Equal As Strings    ${resp.json()[0]['fileType']}    ${fileType}
    # Should Be Equal As Strings    ${resp.json()[0]['action']}      ${FileAction[0]}

    comment  Upload business logo image

    ${cookie}  ${resp}=   Imageupload.spLogin  ${number}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=  uploadLogoImages   ${cookie}  ${jpgfile}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${resp}=    Get Business Logo
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    comment  Upload cover photo

    ${cookie}  ${resp}=   Imageupload.spLogin  ${number}  ${PASSWORD}
    # Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    ${caption1}=  Fakerlibrary.Sentence
    ${resp}=    Upload Cover Picture  ${cookie}  ${caption1}  ${coverpic}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
    ${fileSize}=  OperatingSystem.Get File Size  ${coverpic}
    # ${inMB}=  Evaluate  ${fileSize/1024*1024}
    # ${inMB_rounded}=  Evaluate  round(${${fileSize/1024}/1024}, 3)
    ${inMB_rounded}=  Evaluate  round(${fileSize} / (1024 * 1024), 3)

    ${type}=  db.getType   ${coverpic}
    # Log  ${type}
    ${fileType}=  Get From Dictionary       ${type}    ${coverpic}
    ${fileType1}=  Remove String    ${fileType}    .
    # ${path} 	${file} = 	Split String From Right 	${coverpic} 	/ 	1
    # ${fileName}  ${file_ext}= 	Split String 	${file}  .
    ${filename}  ${ext}= 	Split String From Right 	${coverpic} 	. 	1
    
    ${resp}=    Get Cover Picture
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  200 
    Should Be Equal As Strings    ${resp.json()[0]['keyName']}       coverjpg
    Should Be Equal As Strings    ${resp.json()[0]['caption']}     ${caption1}
    Should Be Equal As Strings    ${resp.json()[0]['prefix']}    cover
    Should Be Equal As Strings    ${resp.json()[0]['type']}    ${fileType1}
    Should Be Equal As Strings    ${resp.json()[0]['originalName']}    ${filename}
    Should Be Equal As Strings    ${resp.json()[0]['size']}    ${inMB_rounded}
    Should Be Equal As Strings    ${resp.json()[0]['contentLength']}      ${fileSize}

    comment  change account details.

    ${resp}=  Get Provider Details    ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${provider_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}       ${number}
    # Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${number}${P_Email}.${test_mail}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${email}  ${firstName1}${number}.${test_mail}
    ${resp}=   Update Service Provider With Emailid    ${provider_id}  ${firstName1}  ${lastName1}  ${gender}  ${dob}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Provider Details    ${provider_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}          ${provider_id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}   ${firstname1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}    ${lastName1}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}       ${number}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}        ${number}.${email}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['emailVerified']}   ${bool[1]} 
    Should Be Equal As Strings  ${resp.json()['basicInfo']['phoneVerified']}   ${bool[1]}

    ${resp}=   Encrypted Provider Login  ${number}.${email}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Provider Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Encrypted Provider Login  ${number}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Provider Logout
    # Should Be Equal As Strings  ${resp.status_code}  200

    comment  check account contact informtion

    ${resp}=  Get Account contact information
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Get customer salutations
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${salutation}=  Random Element    ${resp.json()}
    # Log  ${salutation['name']}
    # ${salutation}=  Evaluate  random.choice($salutations)  random
    ${salutation}=  Random Element    ${salutations}

    ${resp}=  Update Account contact information   ${number}   ${number}.${email}  ${PUSERPH}   ${PUSERPH}  ${number}.${email}  ${salutation}  ${firstname}  ${lastname}  ${countryCodes[1]}  ${countryCodes[1]}  ${countryCodes[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account contact information
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

