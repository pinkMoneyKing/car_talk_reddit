// Im using ImmutableJS.

// Function that fires with onClick in the child compoent and updates two values on the backend.
const handleModalSave = async() => {
    // first save the notes
    // then save the updated value
    setSaving(true);
    // first save the notes, then save the updated value
    const dependencyKey = dependency.get('_id', '');
    const dependencyValue = notes;

    const dropdownValue = temp_dropdownValue;
    const dropdownKey = id;

    await handleSave({key: dependencyKey, value: dependencyValue});
    await handleSave({key: dropdownKey, value: dropdownValue});

    closeModal();
    setDropdownValue('');

    setSaving(false);
};

/// This is the hook state of the parent component that does the saving.
const [loading, setLoading] = useState(false);
// this is the main obj data { key: {obj}, key: {obj}}
// that gest passed down and broken up between a couple different components.
const [vaData, setVAData] = useState(Immutable.Map({})); 
// Redux vars
// Not everything is immutable. 
const assessmentIDs = useSelector(state => state.assess.assessmentIDsArray);
// id_place isn't really the name i use for my properties.
const id = useSelector(state => state.id_place._id) || ''; 
const token = useSelector(state => state.auth.token) || ''; 

// This is the function that is passed down to the components to be used on
// updates
const handleSave = async({key, value}) => {
    try {
        const updatedValues = await bulkSaveUpdatedValues({key, value});
        if(updatedValues.filter(value => value.error).length){
            // Silent errors best erros. jk, just haven't gotten here yet.
        } else {
            // There could be 100 assessments that were updated, we only ever care
            // about the first one.
            const firstValue = Immutable.fromJS(updatedValues[0]);
            const updatedValue = firstValue.getIn(['data', key], '');
            await updateKeyValueAfterSave(key, updatedValue);
        }
    } catch(error){
        const message = 'Error caught in VisualAssessmentContainer/handleSave';
        catchBlockErrors({error, message});
    }
}

// this loops through the assessmentIDs and makes a post call to the backend to
// save the new key value pairs.
const bulkSaveUpdatedValues = async({key, value}) => {
    try {
        const promises = assessmentIDs.map(async(assessmentID, index) => {
                const payload = { id, token, key, value, assessmentID };
                const apiResponse = await updateAssessmentKeyValuePair(payload);
                if(apiResponse.data){
                    const updatedObject = apiResponse.data;
                    return {error: false, data: updatedObject};
                } else if(apiResponse.error){
                    const error = apiResponse.error;
                    return {error: true, data: error};
                }
            })
        return Promise.all(promises);
    } catch(error){
        const message = "Error caught in VisualAssessmentContainer/bulkSaveUpdatedValues";
        catchBlockErrors({error, message});
    }
};


// HERE IS MY QUESTION,
// WHY IS THIS FUNCTION CORRECT
const updateKeyValueAfterSave = (key, value) => {
    return setVAData(vaData => vaData.setIn([key, 'value'], value));
};

// AND THIS FUNCTION IS WRONG AND INCORRECTLY UPDATES MY COMPONENTS
const updateKeyValueAfterSave = (key, value) => {
    const _updatedState = vaData.setIn([key, 'value'], value));
    setVAData(_updatedState);

};
