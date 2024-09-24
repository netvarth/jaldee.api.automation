*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Location
Library           Collections
Library           String
Library           json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Resource        /ebs/TDD/ProviderConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***

JD-TC-GetLocations-1
      [Documentation]  Get Locations by provider login
      ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+440010
      ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup without Profile  PhoneNumber=${PUSERNAME_A}
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      Set Suite Variable  ${PUSERNAME_A}

      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${address1}=  get_random_location_data
      ${tz1}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}      
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  ${postcode1}  ${address1}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid1}  ${resp.json()}

      ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${address2}=  get_random_location_data
      ${tz2}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}      
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  ${postcode2}  ${address2}  
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid2}  ${resp.json()}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      Should Be Equal As Strings  ${resp.json()[0]['id']}  ${lid1}
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city1}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi1}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti1}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode1}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address1}
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ${status[0]}
      Should Be Equal As Strings  ${resp.json()[0]['baseLocation']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()[0]['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()[0]['timezone']}  ${tz1}

      Should Be Equal As Strings  ${resp.json()[1]['id']}  ${lid2}
      Should Be Equal As Strings  ${resp.json()[1]['place']}  ${city2}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi2}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti2}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode2}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address2}
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ${status[0]}
      Should Be Equal As Strings  ${resp.json()[1]['baseLocation']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()[1]['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()[1]['timezone']}  ${tz2}

JD-TC-GetLocations-2
      [Documentation]  Get Locations by user login

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User

      ${resp}=    Provider Logout
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['id']}  ${lid1}      
      Should Be Equal As Strings  ${resp.json()[1]['id']}  ${lid2}


JD-TC-GetLocations-3
      [Documentation]  Create location by user and see if its listed in Get Locations

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${PUSERNAME_U1}  ${u_id} =  Create and Configure Sample User  admin=${bool[1]}

      ${resp}=    Provider Logout
      Should Be Equal As Strings  ${resp.status_code}    200

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}   200

      ${latti3}  ${longi3}  ${postcode3}  ${city3}  ${address3}=  get_random_location_data
      ${tz3}=   db.get_Timezone_by_lat_long   ${latti3}  ${longi3}
      ${resp}=  Create Location  ${city3}  ${longi3}  ${latti3}  ${postcode3}  ${address3}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid3}  ${resp.json()}

      ${resp}=  Get Locations
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200

      Should Be Equal As Strings  ${resp.json()[2]['id']}  ${lid3}
      Should Be Equal As Strings  ${resp.json()[2]['place']}  ${city3}
      Should Be Equal As Strings  ${resp.json()[2]['longitude']}  ${longi3}
      Should Be Equal As Strings  ${resp.json()[2]['lattitude']}  ${latti3}
      Should Be Equal As Strings  ${resp.json()[2]['pinCode']}  ${postcode3}
      Should Be Equal As Strings  ${resp.json()[2]['address']}  ${address3}
      Should Be Equal As Strings  ${resp.json()[2]['status']}  ${status[0]}
      Should Be Equal As Strings  ${resp.json()[2]['baseLocation']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()[2]['open24hours']}  ${bool[0]}
      Should Be Equal As Strings  ${resp.json()[2]['searchable']}  ${bool[1]}
      Should Be Equal As Strings  ${resp.json()[2]['timezone']}  ${tz3}
      

JD-TC-GetLocations -UH1
      [Documentation]   Get locations without login  
      ${resp}=  Get Locations
      Should Be Equal As Strings    ${resp.status_code}   419
      Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-GetLocations -UH2
      [Documentation]   Consumer Get locations
      ${account_id}=    get_acc_id       ${PUSERNAME_A}

      ${primaryMobileNo}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME1}

      ${resp}=    ProviderConsumer Login with token   ${CUSERNAME1}  ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Get Locations
      Should Be Equal As Strings    ${resp.status_code}   401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


                                                     

