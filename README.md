# Welcome to DogBreeds

## About the project:
The given project is a solution for displaying breed images from the public API from https://dog.ceo/dog-api/documentation/.

## App usage:

![app usage](https://user-images.githubusercontent.com/6562493/167784145-2f3e7a2c-57c9-4269-817a-194fc563a9a9.gif)


## Notes about the implementation:
1. Integrating Alamofire using CocoaPods for networking
  1.1. Pros:
    - faster development of small app
  1.2. Cons:
    - harder to implement unit tests (another layer of abstraction could be added between AF and web services or other ways of mocking the AF should be applied)
    - introducing workspace structure which is overengineering for this task. (Using sub-projects structure if using `pod install --no-integrate` is a solution but it also will take time).
    
2. Using 'final' keywords for classes to increase the performance by reducing dynamic dispatch

3. Injecting dependencies into an object instead of requiring the object to initialize them
  Dependency Injection
  
5. Using segues for navigation
  - it is faster for the purposes of the task
  - the navigation could be improved using coordinator pattern or router

4. Fetching all the data for breed and its sub-breeds from https://dog.ceo/api/breeds/list/all
 and skipping https://dog.ceo/api/breed/%@/list for taking sub-breeds
  - It would be better the sub breed controller to fetch its data with only given breed.
