import torch
import numpy as np
import cv2
from time import time
from ultralytics import YOLO


#Initialize the class ObjectDetection
class ObjectDetection:
    
    def __init__(self, capture_index):
       
        self.capture_index = capture_index  #capture_index represents the index of a camera or video source
        
	#checks if CUDA is available on the system
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        print("Using Device: ", self.device)
        
	#loads a pre-trained YOLO model
        self.model = self.load_model()

        #contains a dictionary of class names used by the YOLO model
        self.CLASS_NAMES_DICT = self.model.model.names
        

    #function for loading the desired YOLOv8 model
    def load_model(self):
       
        model = YOLO("best.pt")  # load a pretrained YOLOv8n model
        model.fuse() #fuse the model to improve efficiency/speed during inference
    
        return model

    #function for model prediction
    def predict(self, frame):
       
        results = self.model(frame) #passes the camera frame to loaded YOLO model
        
        return results
    
    #function for plotting bounding boxes on frame 
    def plot_bboxes(self, results, frame):
        
	#Lists and variables initialization
        xyxys = []
        centers = []
        mappedcenters = []
        confidences = []
        class_ids = []
        
        
        original_width = 1280
        original_height = 720
        new_min_x = -400
        new_max_x = 400
        new_min_y = 400
        new_max_y = 0
        
         # Loop over Detection Results
        for result in results:
            boxes = result.boxes.cpu().numpy()
            xyxys = boxes.xyxy
           
            #Bounding Box Drawing 
            for xyxy in xyxys:
		#Draws a rectangle for each bounding box on the the input frame 
            	cv2.rectangle(frame,(int(xyxy[0]), int(xyxy[1])),(int(xyxy[2]),int(xyxy[3])),(225,0,0),2)
            	#print(xyxy)
            	
            	#Bounding Box Center Point Calculation
            	center_x = (int(xyxy[0]) + int(xyxy[2])) / 2
            	center_y = (int(xyxy[1]) + int(xyxy[3])) / 2
            	print("center coordinates: ",center_x,center_y)
            	centers.append((center_x, center_y)) #center coordinates appended to 'centers' list

            	# Calculate mapped coordinates in the new frame
            	mappedcenter_x = int((center_x / original_width) * (new_max_x - new_min_x) + new_min_x)
            	mappedcenter_y = int((center_y / original_height) * (new_max_y - new_min_y) + new_min_y)
            	
            	print("mapped center coordinates: ",mappedcenter_x,mappedcenter_y)
            	mappedcenters.append((mappedcenter_x, mappedcenter_y))
            	
            	# Save results in txt format
            	with open('results.txt', 'w') as f:
            		for mappedcenter in mappedcenters:
            			#f.write(f"{mappedcenter[0]},{mappedcenter[1]} \n")
            			f.write("{:.2f},{:.2f}\n".format(mappedcenter[0],mappedcenter[1]))  # Format the float number with 6 decimal places and write it to the file
        return frame #returns modified input frame containing drawn bounging boxes
    
    
    #Responsible for starting the object detection process
    #Allows the object 'self' to be callable like a function
    def __call__(self):

        cap = cv2.VideoCapture(self.capture_index)
        assert cap.isOpened() #checks if the video capture object is successfully opened
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280) #camera width changed back to 1280
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720) #camera height changed back to 720
      	
	#Frame Capture and Processing Loop
        while True: #Endless loop for capturing frame from video feed
          
            start_time = time() #Measure the start time
            
            ret, frame = cap.read() #Read a fream from 'cap'
            assert ret
            
            results = self.predict(frame) #Use 'predict' method for object detection on the frame and put output results to 'results'
            frame = self.plot_bboxes(results, frame)
            
            end_time = time() #Measure the end time 
            fps = 1/np.round(end_time - start_time, 2) #Calculate frames per second (FPS)
            
	    #Displaying FPS
            cv2.putText(frame, f'FPS: {int(fps)}', (20,70), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0,255,0), 2)
            
            cv2.imshow('YOLOv8 Detection', frame)
 	    
	    #Exit the loop and terminate program if ESC key is pressed
            if cv2.waitKey(5) & 0xFF == 27:
                
                break
        
	#Cleanup
        cap.release()
        cv2.destroyAllWindows()
        
        
    
detector = ObjectDetection(capture_index=4) #creates an instance of ObjectDetection class, '4' is the index for webcam source
detector() #calls the object in the manner of a function call
