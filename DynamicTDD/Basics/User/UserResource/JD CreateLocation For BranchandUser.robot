*** Settings ***

Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Location
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-CreateLocation-1
	[Documentation]  Create a location in account level ${PUSERNAME5}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200


      # clear_location   ${PUSERNAME5}

      ${latti}  ${longi}  ${postcode}  ${citya}  ${district}  ${state}  ${address}=  get_loc_details
      ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
      Set Suite Variable  ${tz}

      # ${citya}=   get_place
      Set Suite Variable  ${citya}
      # ${latti}=  get_latitude
      Set Suite Variable  ${latti}
      # ${longi}=  get_longitude
      Set Suite Variable  ${longi}
      # ${postcode}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode}
      # ${address}=  get_address
      Set Suite Variable  ${address}
      ${parking}    Random Element   ${parkingType}
      Set Suite Variable  ${parking}
      ${24hours}    Random Element    ${bool}
      Set Suite Variable  ${24hours}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY}
	  ${list}=  Create List  1  2  3  4  5  6  7
    	Set Suite Variable  ${list}
      ${sTime0}=  add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${sTime0}
      ${eTime0}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime0}
      ${resp}=  Get Locations
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${citya}  ${longi}  ${latti}  www.${citya}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime0}  ${eTime0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${lid}  ${resp.json()}

JD-TC-CreateLocation-2
	[Documentation]  Create multiple locations in account level
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_D}=  Evaluate  ${PUSERNAME}+9898110
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_D}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_D}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_D}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_D}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_D}${\n}
     Set Suite Variable  ${PUSERNAME_D}
     ${id}=  get_id  ${PUSERNAME_D}
     Set Suite Variable  ${id}
      # ${city1}=   get_place
      # Set Suite Variable  ${city1}
      # ${latti1}=  get_latitude
      # Set Suite Variable  ${latti1}
      # ${longi1}=  get_longitude
      # Set Suite Variable  ${longi1}
      # ${postcode1}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode1}
      # ${address1}=  get_address
      # Set Suite Variable  ${address1}
      ${latti1}  ${longi1}  ${postcode1}  ${city1}  ${district}  ${state}  ${address1}=  get_loc_details
      ${tz1}=   db.get_Timezone_by_lat_long   ${latti1}  ${longi1}
      Set Suite Variable  ${tz1}
      Set Suite Variable  ${city1}
      Set Suite Variable  ${latti1}
      Set Suite Variable  ${longi1}
      Set Suite Variable  ${postcode1}
      Set Suite Variable  ${address1}
      ${parking_type1}    Random Element   ${parkingType}
      Set Suite Variable  ${parking_type1}
      ${24hours1}    Random Element    ${bool}
      Set Suite Variable  ${24hours1}
      ${sTime1}=  add_timezone_time  ${tz}  0  35  
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime1}
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${city2}=   get_place
      # Set Suite Variable  ${city2}
      # ${latti2}=  get_latitude
      # Set Suite Variable  ${latti2}
      # ${longi2}=  get_longitude
      # Set Suite Variable  ${longi2}
      # ${postcode2}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode2}
      # ${address2}=  get_address
      # Set Suite Variable  ${address2}
      ${latti2}  ${longi2}  ${postcode2}  ${city2}  ${district}  ${state}  ${address2}=  get_loc_details
      ${tz2}=   db.get_Timezone_by_lat_long   ${latti2}  ${longi2}
      Set Suite Variable  ${tz2}
      Set Suite Variable  ${city2}
      Set Suite Variable  ${latti2}
      Set Suite Variable  ${longi2}
      Set Suite Variable  ${postcode2}
      Set Suite Variable  ${address2}
      ${parking_type2}    Random Element   ${parkingType}
      Set Suite Variable  ${parking_type2}
      ${24hours2}    Random Element    ${bool}
      Set Suite Variable   ${24hours2}
      ${sTime2}=  add_timezone_time  ${tz}  0  45  
      Set Suite Variable   ${sTime2}
      ${eTime2}=  add_timezone_time  ${tz}  0  50  
      Set Suite Variable   ${eTime2}
      ${resp}=  Create Location  ${city2}  ${longi2}  ${latti2}  www.${city2}.com  ${postcode2}  ${address2}  ${parking_type2}  ${24hours2}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-3
      [Documentation]  Create a location in account level which has same longittude and lattitude
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+9898111
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
     Set Suite Variable  ${PUSERNAME_E}
     ${id}=  get_id  ${PUSERNAME_E}
      # ${city3}=   get_place
      # Set Suite Variable  ${city3}
      # ${latti3}=  get_latitude
      # Set Suite Variable  ${latti3}
      # ${longi3}=  get_longitude
      # Set Suite Variable  ${longi3}
      # ${postcode3}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode3}
      # ${address3}=  get_address
      # Set Suite Variable  ${address3}
      ${latti3}  ${longi3}  ${postcode3}  ${city3}  ${district}  ${state}  ${address3}=  get_loc_details
      ${tz3}=   db.get_Timezone_by_lat_long   ${latti3}  ${longi3}
      Set Suite Variable  ${tz3}
      Set Suite Variable  ${city3}
      Set Suite Variable  ${latti3}
      Set Suite Variable  ${longi3}
      Set Suite Variable  ${postcode3}
      Set Suite Variable  ${address3}
      ${parking_type3}    Random Element   ${parkingType}
      Set Suite Variable  ${parking_type3}
      ${24hours3}    Random Element    ${bool}
      Set Suite Variable  ${24hours3}
      ${resp}=  Create Location  ${city3}  ${longi3}  ${latti3}  www.${city3}.com  ${postcode3}  ${address3}  ${parking_type3}  ${24hours3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city4}=   FakerLibrary.last_name
      Set Suite Variable  ${city4}
      ${postcode4}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode4}
      ${address4}=  get_address
      Set Suite Variable  ${address4}
      ${resp}=  Create Location  ${city4}  ${longi3}  ${latti3}  www.${city4}.com  ${postcode4}  ${address4}  ${parking_type3}  ${24hours3}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-4
      [Documentation]  Create a location which has same pincode in account level
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+9898112
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_F}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_F}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_F}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_F}${\n}
     Set Suite Variable  ${PUSERNAME_F}
     ${id}=  get_id  ${PUSERNAME_F}
      # ${city5}=   get_place
      # Set Suite Variable  ${city5}
      # ${latti5}=  get_latitude
      # Set Suite Variable  ${latti5}
      # ${longi5}=  get_longitude
      # Set Suite Variable  ${longi5}
      # ${postcode5}=  FakerLibrary.postcode
      # Set Suite Variable  ${postcode5}
      # ${address5}=  get_address
      # Set Suite Variable  ${address5}
      ${latti5}  ${longi5}  ${postcode5}  ${city5}  ${district}  ${state}  ${address5}=  get_loc_details
      ${tz5}=   db.get_Timezone_by_lat_long   ${latti5}  ${longi5}
      Set Suite Variable  ${tz5}
      Set Suite Variable  ${city5}
      Set Suite Variable  ${latti5}
      Set Suite Variable  ${longi5}
      Set Suite Variable  ${postcode5}
      Set Suite Variable  ${address5}
      ${parking_type5}    Random Element   ${parkingType}
      Set Suite Variable  ${parking_type5}
      ${24hours5}    Random Element    ${bool}
      Set Suite Variable  ${24hours5}
      ${resp}=  Create Location  ${city5}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city6}=   FakerLibrary.state
      Set Suite Variable  ${city6}
      ${resp}=  Create Location  ${city6}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-CreateLocation-UH1
      [Documentation]  Create a location for a user in a branch
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

      ${u_id}=  Create Sample User
      Set Suite Variable  ${u_id}

      ${resp}=  Get User By Id  ${u_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${PUSERNAME_U1}  ${resp.json()['mobileNo']}

      ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
      Should Be Equal As Strings  ${resp.status_code}  200
       @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
      Should Be Equal As Strings  ${resp[0].status_code}  200
      Should Be Equal As Strings  ${resp[1].status_code}  200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${city7}=   get_place
      Set Suite Variable  ${city7}
      ${latti7}=  get_latitude
      Set Suite Variable  ${latti7}
      ${longi7}=  get_longitude
      Set Suite Variable  ${longi7}
      ${postcode7}=  FakerLibrary.postcode
      Set Suite Variable  ${postcode7}
      ${address7}=  get_address
      Set Suite Variable  ${address7}
      ${parking_type7}    Random Element   ${parkingType}
      Set Suite Variable  ${parking_type7}
      ${24hours7}    Random Element    ${bool}
      Set Suite Variable  ${24hours7}
      ${resp}=  Create Location  ${city7}  ${longi7}  ${latti7}  www.${city7}.com  ${postcode7}  ${address7}  ${parking_type7}  ${24hours7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  ${resp.json()}    ${NOT_PERMITTED_TO_CREATE_LOCATION}


# JD-TC-CreateLocation-6
#       [Documentation]  Create a multiple locations for a user in a branch
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
#       Log  ${resp.json()}
#       Should Be Equal As Strings    ${resp.status_code}    200
#       ${city8}=   FakerLibrary.state
#       Set Suite Variable  ${city8}
#       ${resp}=  Create Location  ${city8}  ${longi7}  ${latti7}  www.${city7}.com  ${postcode7}  ${address7}  ${parking_type7}  ${24hours7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-CreateLocation-UH2
      [Documentation]  Create a location which is already created
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city6}  ${longi5}  ${latti5}  www.${city5}.com  ${postcode5}  ${address5}  ${parking_type5}  ${24hours5}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"

# JD-TC-CreateLocation-UH3
#       [Documentation]  Create same location  for a user in a branch
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
#       Log  ${resp.json()}
#       Should Be Equal As Strings    ${resp.status_code}    200
#       ${resp}=  Create Location  ${city8}  ${longi7}  ${latti7}  www.${city7}.com  ${postcode7}  ${address7}  ${parking_type7}  ${24hours7}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  422
#       Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_EXISTS}"

      sleep  02s
JD-TC-VerifyCreateLocation-1
	[Documentation]  Verify location details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME5}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Location ById  ${lid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  place=${citya}  longitude=${longi}  lattitude=${latti}  pinCode=${postcode}  address=${address}  parkingType=${parking}  open24hours=${24hours}  googleMapUrl=www.${citya}.com  status=ACTIVE
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime0}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime0}

JD-TC-VerifyCreateLocation-2
	[Documentation]  Verify location details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_D}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city1}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi1}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti1}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode1}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address1}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city1}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type1}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours1}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city2}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi2}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti2}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode2}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address2}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city2}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type2}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours2}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime2}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime2}

JD-TC-VerifyCreateLocation-3
	[Documentation]  Verify location details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city3}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi3}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti3}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode3}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address3}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city3}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type3}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours3}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city4}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi3}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti3}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode4}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address4}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city4}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type3}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours3}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

JD-TC-VerifyCreateLocation-4
	[Documentation]  Verify location details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city5}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city6}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}


JD-TC-VerifyCreateLocation-5
	[Documentation]  Verify location details by user login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city5}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city6}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      # Should Be Equal As Strings  ${resp.json()[2]['place']}  ${city7}
      # Should Be Equal As Strings  ${resp.json()[2]['longitude']}  ${longi7}
      # Should Be Equal As Strings  ${resp.json()[2]['lattitude']}  ${latti7}
      # Should Be Equal As Strings  ${resp.json()[2]['pinCode']}  ${postcode7}
      # Should Be Equal As Strings  ${resp.json()[2]['address']}  ${address7}
      # Should Be Equal As Strings  ${resp.json()[2]['googleMapUrl']}  www.${city7}.com
      # Should Be Equal As Strings  ${resp.json()[2]['status']}  ACTIVE
      # Should Be Equal As Strings  ${resp.json()[2]['parkingType']}  ${parking_type7}
      # Should Be Equal As Strings  ${resp.json()[2]['open24hours']}  ${24hours7}
      # Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      # Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

JD-TC-VerifyCreateLocation-6
	[Documentation]  Verify location details by user login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Locations
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()[0]['place']}  ${city5}
      Should Be Equal As Strings  ${resp.json()[0]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[0]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[0]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[0]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[0]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[0]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[0]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[0]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[0]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      Should Be Equal As Strings  ${resp.json()[1]['place']}   ${city6}
      Should Be Equal As Strings  ${resp.json()[1]['longitude']}  ${longi5}
      Should Be Equal As Strings  ${resp.json()[1]['lattitude']}  ${latti5}
      Should Be Equal As Strings  ${resp.json()[1]['pinCode']}  ${postcode5}
      Should Be Equal As Strings  ${resp.json()[1]['address']}  ${address5}
      Should Be Equal As Strings  ${resp.json()[1]['googleMapUrl']}  www.${city5}.com
      Should Be Equal As Strings  ${resp.json()[1]['status']}  ACTIVE
      Should Be Equal As Strings  ${resp.json()[1]['parkingType']}  ${parking_type5}
      Should Be Equal As Strings  ${resp.json()[1]['open24hours']}  ${24hours5}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()[1]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      # Should Be Equal As Strings  ${resp.json()[2]['place']}  ${city7}
      # Should Be Equal As Strings  ${resp.json()[2]['longitude']}  ${longi7}
      # Should Be Equal As Strings  ${resp.json()[2]['lattitude']}  ${latti7}
      # Should Be Equal As Strings  ${resp.json()[2]['pinCode']}  ${postcode7}
      # Should Be Equal As Strings  ${resp.json()[2]['address']}  ${address7}
      # Should Be Equal As Strings  ${resp.json()[2]['googleMapUrl']}  www.${city7}.com
      # Should Be Equal As Strings  ${resp.json()[2]['status']}  ACTIVE
      # Should Be Equal As Strings  ${resp.json()[2]['parkingType']}  ${parking_type7}
      # Should Be Equal As Strings  ${resp.json()[2]['open24hours']}  ${24hours7}
      # Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      # Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	# Should Be Equal As Strings  ${resp.json()[2]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
      # Should Be Equal As Strings  ${resp.json()[3]['place']}   ${city8}
      # Should Be Equal As Strings  ${resp.json()[3]['longitude']}  ${longi7}
      # Should Be Equal As Strings  ${resp.json()[3]['lattitude']}  ${latti7}
      # Should Be Equal As Strings  ${resp.json()[3]['pinCode']}  ${postcode7}
      # Should Be Equal As Strings  ${resp.json()[3]['address']}  ${address7}
      # Should Be Equal As Strings  ${resp.json()[3]['googleMapUrl']}  www.${city7}.com
      # Should Be Equal As Strings  ${resp.json()[3]['status']}  ACTIVE
      # Should Be Equal As Strings  ${resp.json()[3]['parkingType']}  ${parking_type7}
      # Should Be Equal As Strings  ${resp.json()[3]['open24hours']}  ${24hours7}
      # Should Be Equal As Strings  ${resp.json()[3]['bSchedule']['timespec'][0]['recurringType']}  ${recurringtype[1]}
      # Should Be Equal As Strings  ${resp.json()[3]['bSchedule']['timespec'][0]['repeatIntervals']}  ${list}
	# Should Be Equal As Strings  ${resp.json()[3]['bSchedule']['timespec'][0]['startDate']}  ${DAY}
	# Should Be Equal As Strings  ${resp.json()[3]['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	# Should Be Equal As Strings  ${resp.json()[3]['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}
*** Comments ***
JD-TC-CreateLocation-UH5
      [Documentation]   Try to Create more than one location in multipleLocation false domain 
      ${domains}=  get_notiscorp_subdomains_with_no_multilocation  0
      Log  ${domains}
      Set Test Variable  ${dom}  ${domains[0]['domain']}
      Set Test Variable  ${sub_dom}   ${domains[0]['subdomains']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+4300055
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_C}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_C}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_C}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}

      ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime0}  ${eTime0}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Location  ${city1}  ${longi1}  ${latti1}  www.${city1}.com  ${postcode1}  ${address1}  ${parking_type1}  ${24hours1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_CREATION_NOT_ALLOWED}"  


