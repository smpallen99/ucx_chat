
export function remove(arr, item) {
  console.log('remove', arr, item)
    for(var i = arr.length; i--;) {
        if(arr[i] === item) {
            arr.splice(i, 1);
        }
    }
}
