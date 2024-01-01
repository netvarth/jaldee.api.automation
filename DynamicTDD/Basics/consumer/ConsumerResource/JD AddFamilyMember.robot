*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FamilyMember
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py



***Variables***

${cc}                               +91
${withspl}                          @#!

*** Test Cases ***

JD-TC-AddFamilyMember-1

      [Documentation]               Consumer adding family details with valid Family Details
      
      ${gender}                     Random Element    ${Genderlist}                   
      ${dob}                        FakerLibrary.Date
      ${fname}                      FakerLibrary. name
      ${lname}                      FakerLibrary.last_name
      ${email}                      FakerLibrary.email
      ${city}                       FakerLibrary.city
      ${state}                      FakerLibrary.state
      ${address}                    FakerLibrary.address
      ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
      ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
      ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
      ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

      Set Suite Variable      ${gender}
      Set Suite Variable      ${dob}
      Set Suite Variable      ${fname}
      Set Suite Variable      ${lname}
      Set Suite Variable      ${email}
      Set Suite Variable      ${city}
      Set Suite Variable      ${state}
      Set Suite Variable      ${address}
      Set Suite Variable      ${primnum}
      Set Suite Variable      ${altno}
      Set Suite Variable      ${numt}
      Set Suite Variable      ${numw}

      ${resp}=                      Consumer Login  ${CUSERNAME11}  ${PASSWORD}
      Log                           ${resp.json()}
      ${parentid}=                  get_id  ${CUSERNAME11}               
      Should Be Equal As Strings    ${resp.status_code}  200
      ${resp}=                      Add Family  ${fname}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${address}  ${primnum}  ${altno}  ${cc}  ${cc}  ${numt}  ${cc}  ${numw}
      Log                           ${resp.json()}
      Set Suite Variable            ${userid}  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${numt}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${numw}
      


JD-TC-AddFamilyMember-2

      [Documentation]               Consumer adding himself as a family member

      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11} 
      Set Suite Variable            ${cfname}   ${resp.json()['firstName']}
      Set Suite Variable            ${clname}   ${resp.json()['lastName']}

      ${resp}=                      Add Family  ${cfname}  ${clname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${address}  ${primnum}  ${altno}  ${cc}  ${cc}  ${numw}    ${cc}  ${numt}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${cfname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${clname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${numw}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${numt}

JD-TC-AddFamilyMember-UH2

      [Documentation]               Consumer adding family details with all details are empty
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${FIRST_NAME_REQUIRED}"

JD-TC-AddFamilyMember-UH3

      [Documentation]               Consumer adding family details where firstname as numbers
       
      ${withnum}                    FakerLibrary.Numerify   text=%%%%
      Set Suite Variable            ${withnum}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${withnum}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${VALID_FIRST_NAME}"

JD-TC-AddFamilyMember-UH4

      [Documentation]               Consumer adding family details where firstname as special Characters
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${withspl}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${VALID_FIRST_NAME}"

JD-TC-AddFamilyMember-UH5

      [Documentation]               Consumer adding family details where last name as empty
       
      ${fname1}                     FakerLibrary. name
      Set Suite Variable            ${fname1}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname1}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${VALID_LAST_NAME}"

JD-TC-AddFamilyMember-UH6

      [Documentation]               Consumer adding family details where lastname as numbers
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname1}  ${withnum}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${VALID_LAST_NAME}"

JD-TC-AddFamilyMember-UH7

      [Documentation]               Consumer adding family details where lastname as special Characters
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname1}  ${withspl}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${VALID_LAST_NAME}"

JD-TC-AddFamilyMember-3

      [Documentation]               Consumer adding family member with Date of birth as empty
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11} 

      ${resp}=                      Add Family  ${fname1}  ${lname}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname1}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}


JD-TC-AddFamilyMember-4

      [Documentation]               Consumer adding family member with gender as empty
       
      ${fname2}                     FakerLibrary. name
      Set Suite Variable            ${fname2}  ${fname2}A
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname2}  ${lname}  ${dob}  ${empty}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname2}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-5

      [Documentation]               Consumer adding family member where whats app number dont have country code
      ${fname3}                      FakerLibrary. name
      Set Suite Variable            ${fname3}  ${fname3}B
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname3}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${numw}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${COUNTRY_CODEREQUIRED_WHATSAPP}"

JD-TC-AddFamilyMember-UH8

      [Documentation]               Consumer adding family member where whats app number having wrong country code
       
      ${wcc}                        FakerLibrary.Numerify   text=###
      Set Suite Variable            ${wcc}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname3}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${wcc}  ${numw}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_WHATSAPP}"

JD-TC-AddFamilyMember-UH9

      [Documentation]               Consumer adding family member where whats app number having less than 10 digits
       
      ${l10}                        FakerLibrary.Numerify   text=%%%%%%%%
      Set Suite Variable            ${l10}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname3}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${l10}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_WHATSAPP}"

JD-TC-AddFamilyMember-UH10

      [Documentation]               Consumer adding family member where whats app number having more than 10 digits
       
      ${m10}                        FakerLibrary.Numerify   text=%%%%%%%%%%%%
      Set Suite Variable            ${m10}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname3}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${m10}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_WHATSAPP}"

JD-TC-AddFamilyMember-6

      [Documentation]               Consumer adding family member with valid country code and whatsapp number
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname3}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${numw}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname3}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${numw}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-UH11

      [Documentation]               Consumer adding family member where telegram number dont have country code
       
      ${fname4}                      FakerLibrary. name
      Set Suite Variable            ${fname4}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname4}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${numt}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${COUNTRY_CODEREQUIRED_TELEGRAM}"

JD-TC-AddFamilyMember-UH12

      [Documentation]               Consumer adding family member where telegram number having wrong country code
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname4}  ${lname}  ${dob}  ${gender}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${wcc}  ${numt}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_TELEGRAM}"

JD-TC-AddFamilyMember-UH13

      [Documentation]               Consumer adding family member where whats app number having less than 10 digits
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname4}  ${lname}  ${dob}  ${gender}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${l10}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_TELEGRAM}"

JD-TC-AddFamilyMember-UH14

      [Documentation]               Consumer adding family member where whats app number having more than 10 digits
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200

      ${resp}=                      Add Family  ${fname4}  ${lname}  ${dob}  ${gender}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${m10}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  422
      Should Be Equal As Strings    ${resp.content}  "${INVALID_TELEGRAM}"

JD-TC-AddFamilyMember-7

      [Documentation]               Consumer adding family member with valid country code and telegram number
       
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname4}  ${lname}  ${dob}  ${gender}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${cc}  ${numt}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname4}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${cc}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${numt}

JD-TC-AddFamilyMember-8

      [Documentation]               Consumer adding family member with blank email id
       
      ${fname5}                     FakerLibrary. name
      Set Suite Variable            ${fname5}  ${fname5}C
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname5}  ${lname}  ${dob}  ${gender}  ${empty}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname5}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-9

      [Documentation]               Consumer adding family member with valid email id
       
      ${fname6}                     FakerLibrary. name
      Set Suite Variable            ${fname6}  ${fname6}D
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname6}  ${lname}  ${dob}  ${gender}  ${email}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname6}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-10
      [Documentation]               Consumer adding family member with email id without format
       
      ${fname7}                     FakerLibrary. name
      Set Suite Variable            ${fname7}  ${fname7}E
      ${wemail}                     FakerLibrary.last_name
      Set Suite Variable            ${wemail}
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname7}  ${lname}  ${dob}  ${gender}  ${wemail}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname7}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${wemail}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-11

      [Documentation]               Consumer adding family member with blank city
       
      ${fname8}                     FakerLibrary. name
      Set Suite Variable            ${fname8}  ${fname8}F
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname8}  ${lname}  ${dob}  ${gender}  ${email}  ${empty}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname8}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-12

      [Documentation]               Consumer adding family member with valid city
       
      ${fname9}                     FakerLibrary. name
      Set Suite Variable            ${fname9}  ${fname9}G
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname9}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname9}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-13

      [Documentation]               Consumer adding family member with blank state
       
      ${fname10}                    FakerLibrary. name
      Set Suite Variable            ${fname10}  ${fname10}H
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname10}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${empty}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname10}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-14

      [Documentation]               Consumer adding family member with valid state
       
      ${fname11}                    FakerLibrary. name
      Set Suite Variable            ${fname11}  ${fname11}I
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname11}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname11}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-15

      [Documentation]               Consumer adding family member with blank address
       
      ${fname12}                    FakerLibrary. name
      Set Suite Variable            ${fname12}  ${fname12}J
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname12}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname12}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-16

      [Documentation]               Consumer adding family member with valid address
       
      ${fname13}                    FakerLibrary. name
      Set Suite Variable            ${fname13}  ${fname13}K
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname13}  ${lname}  ${dob}  ${gender}  ${email}  ${city}  ${state}   ${address}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname13}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-17

      [Documentation]               Consumer adding family member where primary number as empty
       
      ${fname14}                    FakerLibrary. name
      Set Suite Variable            ${fname14}  ${fname14}L
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname14}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname14}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-18

      [Documentation]               Consumer adding family member where primary number having less than 10 digits
       
      ${fname15}                    FakerLibrary. name
      Set Suite Variable            ${fname15}  ${fname15}M
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname15}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${l10}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname15}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-19

      [Documentation]               Consumer adding family member where primary number having more than 10 digits
       
      ${fname16}                    FakerLibrary. name
      Set Suite Variable            ${fname16}  ${fname16}N
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname16}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${m10}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname16}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-20

      [Documentation]               Consumer adding family member with valid primary number
       
      ${fname17}                    FakerLibrary. name
      Set Suite Variable            ${fname17}  ${fname17}O
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname17}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${primnum}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname17}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-21

      [Documentation]               Consumer adding family member where alternative number as empty
       
      ${fname18}                    FakerLibrary. name
      Set Suite Variable            ${fname18}  ${fname18}P
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname18}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${primnum}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname18}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-22

      [Documentation]               Consumer adding family member where Alternative number having less than 10 digits
       
      ${fname19}                    FakerLibrary. name
      Set Suite Variable            ${fname19}  ${fname19}Q
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname19}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${primnum}  ${l10}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname19}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-23

      [Documentation]               Consumer adding family member where Alternative number having more than 10 digits
       
      ${fname20}                    FakerLibrary. name
      Set Suite Variable            ${fname20}  ${fname20}R
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname20}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${primnum}  ${m10}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname20}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}

JD-TC-AddFamilyMember-24

      [Documentation]               Consumer adding family member with valid Alternative number
       
      ${fname21}                    FakerLibrary. name
      Set Suite Variable            ${fname21}  ${fname21}S
      ${resp}=                      Consumer login  ${CUSERNAME11}     ${PASSWORD}    
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      ${parentid}=                  get_id  ${CUSERNAME11}

      ${resp}=                      Add Family  ${fname21}  ${lname}  ${dob}  ${gender}  ${email}   ${city}  ${state}  ${address}  ${primnum}  ${altno}  ${empty}  ${empty}  ${empty}  ${empty}  ${empty}
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Set Suite Variable            ${userid}  ${resp.json()}

      ${resp}=                      ListFamilyMember
      Log                           ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}  200
      Should Be Equal As Strings    ${resp.json()[0]['parent']}                                          ${Parentid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['id']}                               ${userid}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['firstName']}                        ${fname21}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['lastName']}                         ${lname}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['dob']}                              ${dob}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['address']}                          ${address}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['gender']}                           ${gender}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['email']}                            ${email}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['whatsAppNum']['number']}            ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['countryCode']}       ${empty}
      Should Be Equal As Strings    ${resp.json()[0]['userProfile']['telegramNum']['number']}            ${empty}
