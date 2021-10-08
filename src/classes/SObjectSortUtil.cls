public class SObjectSortUtil {

    private List<SObject> listToSort;
    private List<SortProperty> sortProperties = new List<SortProperty>();

    // ctor
    public SObjectSortUtil(List<SObject> listToSort) {
        this.listToSort = listToSort;
    }

    public void addSortProperty(String propertyName) {
        this.addSortProperty(propertyName, 'ASC', null);
    }

    public void addSortProperty(String propertyName, String sortOrder) {
        this.addSortProperty(propertyName, sortOrder, null);
    }
    
    public void addSortProperty(String propertyName, String sortOrder, Map<String, Integer> customValueMap) {
        if (sortOrder != 'DESC') {
            sortOrder = 'ASC'; // set default
        }
        sortProperties.add(new SortProperty(propertyName, sortOrder, customValueMap));
    }

    public List<SObject> sort() {
        if (this.sortProperties.isEmpty()) {
            // no sort properties defined, return original list
            return this.listToSort;
        }

        // "pack" the sortable wrapper list based on the SObject list
        List<Wrapper> wrapperList = new List<Wrapper>();
        for (SObject obj : this.listToSort) {
            wrapperList.add(new Wrapper(obj, this.sortProperties));
        }

        // sort the wrapper list
        wrapperList.sort();

        // "unpack" the SObject list from wrapper list
        List<SObject> retList = new List<SObject>();
        for (Wrapper wrap : wrapperList) {
            retList.add(wrap.obj);
        }

        // return "unpacked" sorted list
        return retList;
    }

    private class Wrapper implements Comparable {

        SObject obj;
        List<SortProperty> sortProperties = new List<SortProperty>();

        // ctor
        public Wrapper(SObject obj, List<SortProperty> sortProperties) {
            this.obj = obj;
            this.sortProperties = sortProperties;
        }

        public Integer compareTo(Object compareTo) {
            SObject compareToObj = ((Wrapper)compareTo).obj;
            Integer returnValue = 0;

            // iterate trough list of sort properties, in order that it was populated.
            // compare the same property on obj1 and obj2 to check for inequality.
            // as soon as property on obj1 is not equal to property on obj2, break the loop.
            // if all properties on obj1 and obj2 are equal, return 0 (meaning objects are equal).
            for (SortProperty sortProperty : sortProperties) {
                Object prop1 = obj.get(sortProperty.propertyName);
                Object prop2 = compareToObj.get(sortProperty.propertyName);

                if (sortProperty.customMap != null) {
                    // if there is a custom map for values provided, use that first
                    Integer val1 = sortProperty.customMap.get(String.valueOf(prop1));
                    Integer val2 = sortProperty.customMap.get(String.valueOf(prop2));

                    if (val1 > val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? 1 : -1;
                    } else if (val1 < val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? -1 : 1;
                    }
                } else if (prop1 instanceOf Date) {
                    if ((Date)prop1 > (Date)prop2) {
                        returnValue = sortProperty.sortType == 'ASC' ? 1 : -1;
                    } else if ((Date)prop1 < (Date)prop2) {
                        returnValue = sortProperty.sortType == 'ASC' ? -1 : 1;
                    }
                } else if (prop1 instanceOf DateTime) {
                    DateTime val1 = (DateTime)prop1;
                    DateTime val2 = (DateTime)prop2;
                    if (val1 > val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? 1 : -1;
                    } else if (val1 < val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? -1 : 1;
                    }
                } else if (prop1 instanceOf Decimal || prop1 instanceOf Integer) {
                    Decimal val1 = (Decimal)prop1;
                    Decimal val2 = (Decimal)prop2;
                    if (val1 > val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? 1 : -1;
                    } else if (val1 < val2) {
                        returnValue = sortProperty.sortType == 'ASC' ? -1 : 1;
                    }
                } else {
                    String stringVal1 = String.valueOf(prop1);
                    String stringVal2 = String.valueOf(prop2);
    
                    if (stringVal1 > stringVal2) {
                        returnValue = sortProperty.sortType == 'ASC' ? 1 : -1;
                    } else if (stringVal1 < stringVal2) {
                        returnValue = sortProperty.sortType == 'ASC' ? -1 : 1;
                    }
                }

                if (returnValue != 0) {
                    break;
                }
            }

            return returnValue;
        }
    }

    public class SortProperty {
        String propertyName;
        String sortType;
        Map<String,Integer> customMap;

        public SortProperty(String propertyName, String sortType, Map<String,Integer> customMap) {
            this.propertyName = propertyName;
            this.sortType = sortType;
            this.customMap = customMap;
        }
    }
}