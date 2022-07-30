export const verifyWhiteList = async () => {
    try{
           const res = await fetch('api/address')
           const tree = res.json()
    return tree
    }catch(error) {
        return { error }
    }
 
}