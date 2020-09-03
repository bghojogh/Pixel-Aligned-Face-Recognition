import scipy.io as sio
import numpy as np
from sklearn.model_selection import train_test_split, KFold
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis as LDA
from scipy.spatial.distance import cdist
from sklearn.preprocessing import normalize
from sklearn.utils import resample
import os
import pickle
from sklearn import preprocessing   # needed for LabelEncoder()
import glob
from PIL import Image
import re
from sklearn.model_selection import GridSearchCV
#import matplotlib.pyplot as plt
from sklearn.metrics import roc_curve
from sklearn import metrics

################################# Settings:
read_pairs_of_folds_again = False
read_names_of_people_again = False
prepare_train_test_data_again = False
find_patches_again = False
use_shrinkage_LDA = False
path_save_folds = './saved_files/folds/'
path_save_names = './saved_files/names_of_people/'
path_save_train_test_data = './saved_files/train_test_data/'
path_save_patches = './saved_files/patches/'
path_save_results = './saved_files/results/'
path_save_scores = './saved_files/scores/'
experiment_type = 'our_paper'   # 'only_on_raw_dataset' or 'our_paper'  ----> always let it be 'our_paper'
if experiment_type == 'our_paper':
    path_dataset = './dataset_characteristics/lfw/'
    row, col = 92, 112
elif experiment_type == 'only_on_raw_dataset':
    path_dataset = './dataset_raw/lfw/'
    row, col = 250, 250
w_pch, h_pch, n_pch = 30, 30, 80    #--> w_pch: width of patch, h_pch: height of patch, n_pch: number of patches
n_samples_in_downsampling = 7000
number_of_folds = 10

################################# functions:
def save_variable(variable, name_of_variable, path_to_save='./'):
    # https://stackoverflow.com/questions/6568007/how-do-i-save-and-restore-multiple-variables-in-python
    if not os.path.exists(path_to_save):  # https://stackoverflow.com/questions/273192/how-can-i-create-a-directory-if-it-does-not-exist
        os.makedirs(path_to_save)
    file_address = path_to_save + name_of_variable + '.pckl'
    f = open(file_address, 'wb')
    pickle.dump(variable, f)
    f.close()
def load_variable(name_of_variable, path_to_save='./'):
    name_of_variable = name_of_variable + '.pckl'
    file = open(path_to_save+name_of_variable,'rb')
    variable = pickle.load(file)
    file.close()
    return variable
def natsort(list_):
    """ for sorting names of files in human-sense """
    # http://code.activestate.com/recipes/285264-natural-string-sorting/  ---> comment of r8qyfhp02
    # decorate
    tmp = [ (int(re.search('\d+', i).group(0)), i) for i in list_ ]
    tmp.sort()
    # undecorate
    return [ i[1] for i in tmp ]
def read_images(folder_path='./', imagesType='jpg'):
    image_list = []
    images_address = folder_path + '*.' + imagesType
    for filename in natsort(list_=glob.glob(images_address)):
        im = Image.open(filename)    # similar to: im = plt.imread(filename)
        #arr = np.array(im)
        image_list.append(im)
    return image_list
def pilImage2numpyArray(img):
    # https://stackoverflow.com/questions/384759/pil-and-numpy
    if isinstance(img,Image.Image):
        img_arr = np.array(img)
        return img_arr
    else:
        return None
def prepare_train_test_data(fold_index, matched_pairs_folds, mismatched_pairs_folds, numeric_label_transformer, match_or_mismatch='match'):
    # inten_eye_fold, inten_fold, xcoor_fold, ycoor_fold, inten_raw_dataset_fold, xcoorDiff_fold, ycoorDiff_fold = \
    #     np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling)), np.empty((0, n_samples_in_downsampling))
    inten_eye_fold, inten_fold, xcoor_fold, ycoor_fold, inten_raw_dataset_fold, xcoorDiff_fold, ycoorDiff_fold = \
        np.empty((0, row*col)), np.empty((0, row*col)), np.empty((0, row*col)), np.empty((0, row*col)), np.empty((0, row*col)), np.empty((0, row*col)), np.empty((0, row*col))
    labels_fold = []
    ### raw_xcoor:
    raw_xcoor=[]
    for j in range(col):
        raw_xcoor.append([j for i in range(row)])
    raw_xcoor=np.array(raw_xcoor)
    raw_xcoor=raw_xcoor.transpose()
    ### raw_ycoor:
    raw_ycoor=[]
    for j in range(row):
        raw_ycoor.append([j for i in range(col)])
    raw_ycoor=np.array(raw_ycoor)
    ### reading match or mismatch pairs:
    if match_or_mismatch == 'match':
        pairs_in_fold = matched_pairs_folds[fold_index]
    elif match_or_mismatch == 'mismatch':
        pairs_in_fold = mismatched_pairs_folds[fold_index]
    pair_index = 0
    for pair in pairs_in_fold:
        pair_index = pair_index + 1
        print('=================> pair number ' + str(pair_index) + ' out of ' + str(len(pairs_in_fold)) + ' pairs...')
        for index_of_person_in_pair in range(2):
            if match_or_mismatch == 'match':
                name_of_person = pair[0]
                label = numeric_label_transformer.transform([name_of_person])
                if index_of_person_in_pair == 0:
                    index_image_person = int(pair[1]) - 1   #--> we subtract 1 to start indexing from 0
                else:
                    index_image_person = int(pair[2]) - 1   #--> we subtract 1 to start indexing from 0
            elif match_or_mismatch == 'mismatch':
                if index_of_person_in_pair == 0:
                    name_of_person = pair[0]
                    label = numeric_label_transformer.transform([name_of_person])
                    index_image_person = int(pair[1]) - 1   #--> we subtract 1 to start indexing from 0
                else:
                    name_of_person = pair[2]
                    label = numeric_label_transformer.transform([name_of_person])
                    index_image_person = int(pair[3]) - 1   #--> we subtract 1 to start indexing from 0
            path = path_dataset + name_of_person + '/'
            if experiment_type == 'our_paper':
                ### eye-aligned files:
                mat=sio.loadmat(path+'intensity_eye_aligned.mat')
                inten_eye=mat['intensity_eye_aligned']
                ### pixel-aligned files:
                mat=sio.loadmat(path+'intensity.mat')
                inten=mat['intensity']
                mat=sio.loadmat(path+'XP.mat')
                xcoor=mat['XP']
                mat=sio.loadmat(path+'YP.mat')
                ycoor=mat['YP']
                ### eye-aligned files:
                inten_eye = inten_eye[index_image_person]
                inten = inten[index_image_person]
                xcoor = xcoor[index_image_person]
                ycoor = ycoor[index_image_person]
                ### resample (downsample) the files:
                # inten,xcoor,ycoor,inten_eye=resample(inten,xcoor,ycoor,inten_eye,n_samples=n_samples_in_downsampling,replace=None)
                ### pixel-aligned files:
                inten_eye_fold = np.vstack([inten_eye_fold, inten_eye])
                inten_fold = np.vstack([inten_fold, inten])
                xcoor_fold = np.vstack([xcoor_fold, xcoor])
                ycoor_fold = np.vstack([ycoor_fold, ycoor])
            elif experiment_type == 'only_on_raw_dataset':
                ### eye-aligned files:
                image_list = read_images(folder_path=path, imagesType='jpg')
                image = pilImage2numpyArray(image_list[index_image_person])
                image = np.reshape(image, (1, -1))  #--> reshape to a row-wise vector
                ### resample (downsample) the files:
                image=image.astype(np.float32)
                image=resample(image,n_samples=n_samples_in_downsampling,replace=None)
                inten_raw_dataset_fold = np.vstack([inten_raw_dataset_fold, image])
            ### labels:
            label = int(label)
            labels_fold.append(label)
            if experiment_type == 'our_paper':
                ### finding Delta_x:
                x=np.reshape(xcoor,(-1,col))
                x=x.astype(np.float32)
                x=x-raw_xcoor-np.mean(x-raw_xcoor)
                x=np.reshape(x,(1,-1))  #--> reshape to a row-wise vector
                xcoorDiff_fold = np.vstack([xcoorDiff_fold, x])
                ### finding Delta_y:
                y=np.reshape(ycoor,(-1,col))
                y=y.astype(np.float32)
                y=y-raw_ycoor-np.mean(y-raw_ycoor)
                y=np.reshape(y,(1,-1))  #--> reshape to a row-wise vector
                ycoorDiff_fold = np.vstack([ycoorDiff_fold, y])
    return inten_eye_fold, inten_fold, xcoorDiff_fold, ycoorDiff_fold, xcoor_fold, ycoor_fold, inten_raw_dataset_fold, labels_fold

################################# read_pairs_of_folds:
print('Reading pairs of folds...')
if read_pairs_of_folds_again:
    # https://stackoverflow.com/questions/14676265/how-to-read-text-file-into-a-list-or-array-with-python
    list_of_lists = []
    with open('pairs.txt') as f:
        for line in f:
            inner_list = [elt.strip() for elt in line.split('\t')]
            list_of_lists.append(inner_list)
    ###### separating the pairs in folds:
    number_of_lines = len(list_of_lists)
    fold_index = 0
    previous_line_length = 3
    matched_pairs = []
    mismatched_pairs = []
    matched_pairs_folds = [None] * number_of_folds
    mismatched_pairs_folds = [None] * number_of_folds
    for line_index in range(number_of_lines):
        line = list_of_lists[line_index]
        if previous_line_length == 4 and len(line) == 3:
            matched_pairs_folds[fold_index] = matched_pairs[:]
            mismatched_pairs_folds[fold_index] = mismatched_pairs[:]
            matched_pairs = []
            mismatched_pairs = []
            fold_index = fold_index + 1
        # print(fold_index)
        if len(line) == 3:
            matched_pairs.append(line[:])
        elif len(line) == 4:
            mismatched_pairs.append(line[:])
        previous_line_length = len(line)
    matched_pairs_folds[-1] = matched_pairs[:]
    mismatched_pairs_folds[-1] = mismatched_pairs[:]
    save_variable(variable=matched_pairs_folds, name_of_variable='matched_pairs_folds', path_to_save=path_save_folds)
    save_variable(variable=mismatched_pairs_folds, name_of_variable='mismatched_pairs_folds', path_to_save=path_save_folds)
else:
    matched_pairs_folds = load_variable(name_of_variable='matched_pairs_folds', path_to_save=path_save_folds)
    mismatched_pairs_folds = load_variable(name_of_variable='mismatched_pairs_folds', path_to_save=path_save_folds)

################################# read names of people:
print('Reading names of people...')
if read_names_of_people_again:
    # https://stackoverflow.com/questions/14676265/how-to-read-text-file-into-a-list-or-array-with-python
    list_of_lists = []
    with open('people.txt') as f:
        for line in f:
            inner_list = [elt.strip() for elt in line.split('\t')]
            list_of_lists.append(inner_list)
    ###### separating the pairs in folds:
    number_of_lines = len(list_of_lists)
    names_of_people = []
    for line_index in range(number_of_lines):
        line = list_of_lists[line_index]
        name = line[0]
        names_of_people.append(name)
    save_variable(variable=names_of_people, name_of_variable='names_of_people', path_to_save=path_save_names)
else:
    names_of_people = load_variable(name_of_variable='names_of_people', path_to_save=path_save_names)

################################# encode names of people to numbers:
# http://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.LabelEncoder.html
numeric_label_transformer = preprocessing.LabelEncoder()
numeric_label_transformer.fit(names_of_people)

##################################### Preparing train/test data (before patching):
print('Preparing/Reading data of folds...')
inten_eye_Allfolds = [None] * number_of_folds
inten_Allfolds = [None] * number_of_folds
xcoor_Allfolds = [None] * number_of_folds
ycoor_Allfolds = [None] * number_of_folds
inten_raw_dataset_Allfolds = [None] * number_of_folds
labels_Allfolds = [None] * number_of_folds
number_of_match_pairs = [None] * number_of_folds
number_of_mismatch_pairs = [None] * number_of_folds
for test_fold_index in range(number_of_folds):
    print('=====> fold number ' + str(test_fold_index) + ' out of ' + str(number_of_folds) + ' folds...')
    if prepare_train_test_data_again:
        ### reading match-pairs:
        print('==========> reading match pairs...')
        inten_eye_match, inten_match, xcoorDiff_match, ycoorDiff_match, \
            _, _, inten_raw_dataset_match, labels_match = \
            prepare_train_test_data(fold_index=test_fold_index, matched_pairs_folds=matched_pairs_folds,
                                        mismatched_pairs_folds=mismatched_pairs_folds, numeric_label_transformer=numeric_label_transformer, match_or_mismatch='match')
        number_of_match_pairs[test_fold_index] = inten_eye_match.shape[0] / 2
        ### reading mismatch-pairs:
        print('==========> reading mismatch pairs...')
        inten_eye_mismatch, inten_mismatch, xcoorDiff_mismatch, ycoorDiff_mismatch, \
            _, _, inten_raw_dataset_mismatch, labels_mismatch = \
            prepare_train_test_data(fold_index=test_fold_index, matched_pairs_folds=matched_pairs_folds,
                                        mismatched_pairs_folds=mismatched_pairs_folds, numeric_label_transformer=numeric_label_transformer, match_or_mismatch='mismatch')
        inten_eye_match = np.vstack([inten_eye_match, inten_eye_mismatch])
        inten_match = np.vstack([inten_match, inten_mismatch])
        xcoorDiff_match = np.vstack([xcoorDiff_match, xcoorDiff_mismatch])
        ycoorDiff_match = np.vstack([ycoorDiff_match, ycoorDiff_mismatch])
        inten_raw_dataset_match = np.vstack([inten_raw_dataset_match, inten_raw_dataset_mismatch])
        labels_match.extend(labels_mismatch)
        number_of_mismatch_pairs[test_fold_index] = inten_eye_mismatch.shape[0] / 2
        ########################### save files:
        inten_eye_Allfolds[test_fold_index] = inten_eye_match
        inten_Allfolds[test_fold_index] = inten_match
        xcoor_Allfolds[test_fold_index] = xcoorDiff_match
        ycoor_Allfolds[test_fold_index] = ycoorDiff_match
        inten_raw_dataset_Allfolds[test_fold_index] = inten_raw_dataset_match
        labels_Allfolds[test_fold_index] = labels_match
        save_variable(variable=inten_eye_Allfolds, name_of_variable='inten_eye_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=inten_Allfolds, name_of_variable='inten_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=xcoor_Allfolds, name_of_variable='xcoor_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=ycoor_Allfolds, name_of_variable='ycoor_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=inten_raw_dataset_Allfolds, name_of_variable='inten_raw_dataset_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=labels_Allfolds, name_of_variable='labels_Allfolds', path_to_save=path_save_train_test_data)
        save_variable(variable=number_of_match_pairs, name_of_variable='number_of_match_pairs', path_to_save=path_save_train_test_data)
        save_variable(variable=number_of_mismatch_pairs, name_of_variable='number_of_mismatch_pairs', path_to_save=path_save_train_test_data)
if not prepare_train_test_data_again:
    ########################### load files:
    inten_eye_Allfolds = load_variable(name_of_variable='inten_eye_Allfolds', path_to_save=path_save_train_test_data)
    inten_Allfolds = load_variable(name_of_variable='inten_Allfolds', path_to_save=path_save_train_test_data)
    xcoor_Allfolds = load_variable(name_of_variable='xcoor_Allfolds', path_to_save=path_save_train_test_data)
    ycoor_Allfolds = load_variable(name_of_variable='ycoor_Allfolds', path_to_save=path_save_train_test_data)
    inten_raw_dataset_Allfolds = load_variable(name_of_variable='inten_raw_dataset_Allfolds', path_to_save=path_save_train_test_data)
    labels_Allfolds = load_variable(name_of_variable='labels_Allfolds', path_to_save=path_save_train_test_data)
    number_of_match_pairs = load_variable(name_of_variable='number_of_match_pairs', path_to_save=path_save_train_test_data)
    number_of_mismatch_pairs = load_variable(name_of_variable='number_of_mismatch_pairs', path_to_save=path_save_train_test_data)

########################### creating patches only once:
print('Creating/Reading patches in train/test data...')
if find_patches_again:
    inten_eye_All_patch_data = [ [[None] for column_index in range(n_pch)] for row_index in range(number_of_folds) ]
    inten_All_patch_data = [ [[None] for column_index in range(n_pch)] for row_index in range(number_of_folds) ]
    xcoor_All_patch_data = [ [[None] for column_index in range(n_pch)] for row_index in range(number_of_folds) ]
    ycoor_All_patch_data = [ [[None] for column_index in range(n_pch)] for row_index in range(number_of_folds) ]
    x_pch = [None] * n_pch
    y_pch = [None] * n_pch
    for patch_index in range(n_pch):
        print('=====> Patch number ' + str(patch_index) + ' out of ' + str(n_pch) + ' patches...')
        x_pch[patch_index], y_pch[patch_index] = np.random.randint(0, row-h_pch, 1), np.random.randint(0, col-w_pch, 1)
        ### patches on the data:
        for test_fold_index in range(number_of_folds):
            print('===========> Fold number ' + str(test_fold_index) + ' out of ' + str(number_of_folds) + ' folds...')
            inten_eye = inten_eye_Allfolds[test_fold_index]
            inten = inten_Allfolds[test_fold_index]
            xcoor = xcoor_Allfolds[test_fold_index]
            ycoor = ycoor_Allfolds[test_fold_index]
            number_of_samples_in_fold = inten_eye.shape[0]
            inten_eye_patches = np.zeros((number_of_samples_in_fold, h_pch*w_pch))
            inten_patches = np.zeros((number_of_samples_in_fold, h_pch*w_pch))
            xcoor_patches = np.zeros((number_of_samples_in_fold, h_pch*w_pch))
            ycoor_patches = np.zeros((number_of_samples_in_fold, h_pch*w_pch))
            for sample_index in range(number_of_samples_in_fold):
                print('====================> Sample number ' + str(sample_index) + ' out of ' + str(number_of_samples_in_fold) + ' samples...')
                sample = np.reshape(inten_eye[sample_index, :], (-1, col))
                inten_eye_patches[sample_index, :] = np.reshape(sample[int(x_pch[patch_index]):int(x_pch[patch_index]) + h_pch, int(y_pch[patch_index]):int(y_pch[patch_index]) + w_pch], (1, -1))
                sample = np.reshape(inten[sample_index, :], (-1, col))
                inten_patches[sample_index, :] = np.reshape(sample[int(x_pch[patch_index]):int(x_pch[patch_index]) + h_pch, int(y_pch[patch_index]):int(y_pch[patch_index]) + w_pch], (1, -1))
                sample = np.reshape(xcoor[sample_index, :], (-1, col))
                xcoor_patches[sample_index, :] = np.reshape(sample[int(x_pch[patch_index]):int(x_pch[patch_index]) + h_pch, int(y_pch[patch_index]):int(y_pch[patch_index]) + w_pch], (1, -1))
                sample = np.reshape(ycoor[sample_index, :], (-1, col))
                ycoor_patches[sample_index, :] = np.reshape(sample[int(x_pch[patch_index]):int(x_pch[patch_index]) + h_pch, int(y_pch[patch_index]):int(y_pch[patch_index]) + w_pch], (1, -1))
            ### All patches of data:
            inten_eye_All_patch_data[test_fold_index][patch_index] = inten_eye_patches
            inten_All_patch_data[test_fold_index][patch_index] = inten_patches
            xcoor_All_patch_data[test_fold_index][patch_index] = xcoor_patches
            ycoor_All_patch_data[test_fold_index][patch_index] = ycoor_patches
        ### save location of patches:
        save_variable(variable=x_pch, name_of_variable='x_pch', path_to_save=path_save_patches)
        save_variable(variable=y_pch, name_of_variable='y_pch', path_to_save=path_save_patches)
    ### save data of patches:
    save_variable(variable=inten_eye_All_patch_data, name_of_variable='inten_eye_All_patch_data', path_to_save=path_save_patches)
    save_variable(variable=inten_All_patch_data, name_of_variable='inten_All_patch_data', path_to_save=path_save_patches)
    save_variable(variable=xcoor_All_patch_data, name_of_variable='xcoor_All_patch_data', path_to_save=path_save_patches)
    save_variable(variable=ycoor_All_patch_data, name_of_variable='ycoor_All_patch_data', path_to_save=path_save_patches)
else:
    x_pch = load_variable(name_of_variable='x_pch', path_to_save=path_save_patches)
    y_pch = load_variable(name_of_variable='x_pch', path_to_save=path_save_patches)
    inten_eye_All_patch_data = load_variable(name_of_variable='inten_eye_All_patch_data', path_to_save=path_save_patches)
    inten_All_patch_data = load_variable(name_of_variable='inten_All_patch_data', path_to_save=path_save_patches)
    xcoor_All_patch_data = load_variable(name_of_variable='xcoor_All_patch_data', path_to_save=path_save_patches)
    ycoor_All_patch_data = load_variable(name_of_variable='ycoor_All_patch_data', path_to_save=path_save_patches)

##################################### Classification:
print('Classification...')
fpr_inten_patch, tpr_inten_patch, thr_inten_patch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
fpr_fusion1_patch, tpr_fusion1_patch, thr_fusion1_patch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
fpr_fusion2_patch, tpr_fusion2_patch, thr_fusion2_patch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
fpr_inten_eye_patch, tpr_inten_eye_patch, thr_inten_eye_patch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
fpr_inten_eye_NoPatch, tpr_inten_eye_NoPatch, thr_inten_eye_NoPatch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
AUC_inten_patch, AUC_fusion1_patch, AUC_fusion2_patch, AUC_inten_eye_patch, AUC_inten_eye_NoPatch = [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds, [None] * number_of_folds
for test_fold_index in range(number_of_folds):
    print('=====> Fold number ' + str(test_fold_index) + ' out of ' + str(number_of_folds) + ' folds...')
    ### iteration on patches:
    dist_inten_eye_patches = [[] for patch_index in range(n_pch)]  #--> list of lists --> row(index1): patch, column(index2): pair (in test set)
    dist_inten_patches = [[] for patch_index in range(n_pch)]  #--> list of lists --> row(index1): patch, column(index2): pair (in test set)
    dist_xcoor_patches = [[] for patch_index in range(n_pch)]  #--> list of lists --> row(index1): patch, column(index2): pair (in test set)
    dist_ycoor_patches = [[] for patch_index in range(n_pch)]  #--> list of lists --> row(index1): patch, column(index2): pair (in test set)
    for patch_index in range(n_pch):
        print('===========> Patch number ' + str(patch_index) + ' out of ' + str(n_pch) + ' patches...')
        #####-----------> train phase:
        ### prepare train data:
        labels_train_data = []
        inten_eye_train_data = np.empty((0, h_pch*w_pch))
        inten_train_data = np.empty((0, h_pch*w_pch))
        xcoor_train_data = np.empty((0, h_pch*w_pch))
        ycoor_train_data = np.empty((0, h_pch*w_pch))
        for train_fold_index in range(number_of_folds):
            if train_fold_index != test_fold_index:
                labels_train_data.extend(labels_Allfolds[train_fold_index])
                inten_eye_train_data = np.vstack([inten_eye_train_data, inten_eye_All_patch_data[train_fold_index][patch_index]])
                inten_train_data = np.vstack([inten_train_data, inten_All_patch_data[train_fold_index][patch_index]])
                xcoor_train_data = np.vstack([xcoor_train_data, xcoor_All_patch_data[train_fold_index][patch_index]])
                ycoor_train_data = np.vstack([ycoor_train_data, ycoor_All_patch_data[train_fold_index][patch_index]])
        ### train classifier:
        if use_shrinkage_LDA:
            tuned_parameters = [{'shrinkage': [0.1,0.4,0.8]}]
            lda_inten_eye_patches = GridSearchCV(LDA(solver='lsqr'), tuned_parameters, cv=3)
            lda_inten_patches = GridSearchCV(LDA(solver='lsqr'), tuned_parameters, cv=3)
            lda_xcoor_patches = GridSearchCV(LDA(solver='lsqr'), tuned_parameters, cv=3)
            lda_ycoor_patches = GridSearchCV(LDA(solver='lsqr'), tuned_parameters, cv=3)
        else:
            lda_inten_eye_patches = LDA()
            lda_inten_patches = LDA()
            lda_xcoor_patches = LDA()
            lda_ycoor_patches = LDA()
        lda_inten_eye_patches.fit(inten_eye_train_data, labels_train_data)
        lda_inten_patches.fit(inten_train_data, labels_train_data)
        lda_xcoor_patches.fit(xcoor_train_data, labels_train_data)
        lda_ycoor_patches.fit(ycoor_train_data, labels_train_data)

        #####-----------> test phase:
        inten_eye_patches = inten_eye_All_patch_data[test_fold_index][patch_index]
        inten_patches = inten_All_patch_data[test_fold_index][patch_index]
        xcoor_patches = xcoor_All_patch_data[test_fold_index][patch_index]
        ycoor_patches = ycoor_All_patch_data[test_fold_index][patch_index]
        number_of_test_samples_in_fold = inten_eye_patches.shape[0]
        pairwise_label = []
        for test_sample_index in range(0, number_of_test_samples_in_fold, 2):
            print('====================> Test samples number ' + str(test_sample_index) + ' and ' + str(test_sample_index+1) + ' out of ' + str(number_of_test_samples_in_fold) + ' samples...')
            inten_eye_test1_data = inten_eye_patches[test_sample_index, :]
            inten_test1_data = inten_patches[test_sample_index, :]
            xcoor_test1_data = xcoor_patches[test_sample_index, :]
            ycoor_test1_data = ycoor_patches[test_sample_index, :]
            inten_eye_test2_data = inten_eye_patches[test_sample_index+1, :]
            inten_test2_data = inten_patches[test_sample_index+1, :]
            xcoor_test2_data = xcoor_patches[test_sample_index+1, :]
            ycoor_test2_data = ycoor_patches[test_sample_index+1, :]
            inten_eye_test1_proj = lda_inten_eye_patches.transform(inten_eye_test1_data)
            inten_eye_test2_proj = lda_inten_eye_patches.transform(inten_eye_test2_data)
            inten_test1_proj = lda_inten_patches.transform(inten_test1_data)
            inten_test2_proj = lda_inten_patches.transform(inten_test2_data)
            xcoor_test1_proj = lda_xcoor_patches.transform(xcoor_test1_data)
            xcoor_test2_proj = lda_xcoor_patches.transform(xcoor_test2_data)
            ycoor_test1_proj = lda_ycoor_patches.transform(ycoor_test1_data)
            ycoor_test2_proj = lda_ycoor_patches.transform(ycoor_test2_data)
            dist_inten_eye_patches[patch_index].extend(cdist(inten_eye_test1_proj, inten_eye_test2_proj, 'cosine').flatten())
            dist_inten_patches[patch_index].extend(cdist(inten_test1_proj, inten_test2_proj, 'cosine').flatten())
            dist_xcoor_patches[patch_index].extend(cdist(xcoor_test1_proj, xcoor_test2_proj, 'cosine').flatten())
            dist_ycoor_patches[patch_index].extend(cdist(ycoor_test1_proj, ycoor_test2_proj, 'cosine').flatten())
            if test_sample_index < number_of_match_pairs[test_fold_index]*2:  #--> the test samples are match
                pairwise_label.append(1)
            else:   #--> the test samples are mismatch
                pairwise_label.append(0)

    #####-----------> train phase for Eye-aligned Without patches:
    labels_train_data = []
    inten_eye_noPatch_train_data = np.empty((0, row*col))
    for train_fold_index in range(number_of_folds):
        if train_fold_index != test_fold_index:
            labels_train_data.extend(labels_Allfolds[train_fold_index])
            inten_eye_noPatch_train_data = np.vstack([inten_eye_noPatch_train_data, inten_eye_Allfolds[test_fold_index]])
    if use_shrinkage_LDA:
        tuned_parameters = [{'shrinkage': [0.1,0.4,0.8]}]
        lda_inten_eye_noPatch = GridSearchCV(LDA(solver='lsqr'), tuned_parameters, cv=3)
    else:
        lda_inten_eye_noPatch = LDA()
    lda_inten_eye_noPatch.fit(inten_eye_noPatch_train_data, labels_train_data)
    #####-----------> test phase for Eye-aligned Without patches:
    dist_inten_eye_NoPatch = []  #--> list --> index: pair (in test set)
    inten_eye_NoPatch = inten_eye_Allfolds[test_fold_index]
    number_of_test_samples_in_fold = inten_eye_NoPatch.shape[0]
    for test_sample_index in range(0, number_of_test_samples_in_fold, 2):
        inten_eye_NoPatch_test1_data = inten_eye_NoPatch[test_sample_index, :]
        inten_eye_NoPatch_test2_data = inten_eye_NoPatch[test_sample_index+1, :]
        inten_eye_NoPatch_test1_proj = lda_inten_eye_noPatch.transform(inten_eye_NoPatch_test1_data)
        inten_eye_NoPatch_test2_proj = lda_inten_eye_noPatch.transform(inten_eye_NoPatch_test2_data)
        dist_inten_eye_NoPatch.extend(cdist(inten_eye_NoPatch_test1_proj, inten_eye_NoPatch_test2_proj, 'cosine').flatten())

    ### sum up the scores over the patches:
    sc_inten_patch,sc_coor_patch,sc_inten_eye_patch=0,0,0
    for patch_index in range(n_pch):
        sc_inten_patch = sc_inten_patch + np.array(dist_inten_patches[patch_index])
        sc_coor_patch = sc_coor_patch + np.array(dist_xcoor_patches[patch_index])+np.array(dist_ycoor_patches[patch_index])
        sc_inten_eye_patch = sc_inten_eye_patch + np.array(dist_inten_eye_patches[patch_index])
    sc_inten_eye_NoPatch = np.array(dist_inten_eye_NoPatch)

    ### save scores:
    save_variable(variable=sc_inten_patch, name_of_variable='sc_inten_patch', path_to_save=path_save_scores+'fold'+str(test_fold_index)+'/')
    save_variable(variable=sc_coor_patch, name_of_variable='sc_coor_patch', path_to_save=path_save_scores+'fold'+str(test_fold_index)+'/')
    save_variable(variable=sc_inten_eye_patch, name_of_variable='sc_inten_eye_patch', path_to_save=path_save_scores+'fold'+str(test_fold_index)+'/')
    save_variable(variable=sc_inten_eye_NoPatch, name_of_variable='sc_inten_eye_NoPatch', path_to_save=path_save_scores+'fold'+str(test_fold_index)+'/')

    ### Calculate ROC curves:
    fpr_inten_patch[test_fold_index], tpr_inten_patch[test_fold_index], thr_inten_patch[test_fold_index] = roc_curve(pairwise_label,1-sc_inten_patch)
    fpr_fusion1_patch[test_fold_index], tpr_fusion1_patch[test_fold_index], thr_fusion1_patch[test_fold_index] = roc_curve(pairwise_label,1-(sc_inten_patch+0.1*sc_coor_patch))
    fpr_fusion2_patch[test_fold_index], tpr_fusion2_patch[test_fold_index], thr_fusion2_patch[test_fold_index] = roc_curve(pairwise_label,1-(sc_inten_patch+0.2*sc_coor_patch))
    fpr_inten_eye_patch[test_fold_index], tpr_inten_eye_patch[test_fold_index], thr_inten_eye_patch[test_fold_index] = roc_curve(pairwise_label,1-sc_inten_eye_patch)
    fpr_inten_eye_NoPatch[test_fold_index], tpr_inten_eye_NoPatch[test_fold_index], thr_inten_eye_NoPatch[test_fold_index] = roc_curve(pairwise_label,1-sc_inten_eye_NoPatch)

    ### Calculate AUC (Area Under Curve) of ROC curves:
    # http://scikit-learn.org/stable/modules/generated/sklearn.metrics.auc.html
    # http://scikit-learn.org/stable/modules/generated/sklearn.metrics.roc_auc_score.html
    AUC_inten_patch[test_fold_index] = metrics.auc(fpr_inten_patch[test_fold_index], tpr_inten_patch[test_fold_index])
    AUC_fusion1_patch[test_fold_index] = metrics.auc(fpr_fusion1_patch[test_fold_index], tpr_fusion1_patch[test_fold_index])
    AUC_fusion2_patch[test_fold_index] = metrics.auc(fpr_fusion2_patch[test_fold_index], tpr_fusion2_patch[test_fold_index])
    AUC_inten_eye_patch[test_fold_index] = metrics.auc(fpr_inten_eye_patch[test_fold_index], tpr_inten_eye_patch[test_fold_index])
    AUC_inten_eye_NoPatch[test_fold_index] = metrics.auc(fpr_inten_eye_NoPatch[test_fold_index], tpr_inten_eye_NoPatch[test_fold_index])

    ### save (update the saved) results:
    save_variable(variable=fpr_inten_patch, name_of_variable='fpr_inten_patch', path_to_save=path_save_results)
    save_variable(variable=tpr_inten_patch, name_of_variable='tpr_inten_patch', path_to_save=path_save_results)
    save_variable(variable=thr_inten_patch, name_of_variable='thr_inten_patch', path_to_save=path_save_results)
    save_variable(variable=fpr_fusion1_patch, name_of_variable='fpr_fusion1_patch', path_to_save=path_save_results)
    save_variable(variable=tpr_fusion1_patch, name_of_variable='tpr_fusion1_patch', path_to_save=path_save_results)
    save_variable(variable=thr_fusion1_patch, name_of_variable='thr_fusion1_patch', path_to_save=path_save_results)
    save_variable(variable=fpr_fusion2_patch, name_of_variable='fpr_fusion2_patch', path_to_save=path_save_results)
    save_variable(variable=tpr_fusion2_patch, name_of_variable='tpr_fusion2_patch', path_to_save=path_save_results)
    save_variable(variable=thr_fusion2_patch, name_of_variable='thr_fusion2_patch', path_to_save=path_save_results)
    save_variable(variable=fpr_inten_eye_patch, name_of_variable='fpr_inten_eye_patch', path_to_save=path_save_results)
    save_variable(variable=tpr_inten_eye_patch, name_of_variable='tpr_inten_eye_patch', path_to_save=path_save_results)
    save_variable(variable=thr_inten_eye_patch, name_of_variable='thr_inten_eye_patch', path_to_save=path_save_results)
    save_variable(variable=fpr_inten_eye_NoPatch, name_of_variable='fpr_inten_eye_NoPatch', path_to_save=path_save_results)
    save_variable(variable=tpr_inten_eye_NoPatch, name_of_variable='tpr_inten_eye_NoPatch', path_to_save=path_save_results)
    save_variable(variable=thr_inten_eye_NoPatch, name_of_variable='thr_inten_eye_NoPatch', path_to_save=path_save_results)
    save_variable(variable=AUC_inten_patch, name_of_variable='AUC_inten_patch', path_to_save=path_save_results)
    save_variable(variable=AUC_fusion1_patch, name_of_variable='AUC_fusion1_patch', path_to_save=path_save_results)
    save_variable(variable=AUC_fusion2_patch, name_of_variable='AUC_fusion2_patch', path_to_save=path_save_results)
    save_variable(variable=AUC_inten_eye_patch, name_of_variable='AUC_inten_eye_patch', path_to_save=path_save_results)
    save_variable(variable=AUC_inten_eye_NoPatch, name_of_variable='AUC_inten_eye_NoPatch', path_to_save=path_save_results)

    # ### Plot ROC curves:
    # plt.plot(fpr_inten_patch,tpr_inten_patch,color='green',label='intensity')
    # plt.plot(fpr_fusion1_patch,tpr_fusion1_patch,color='blue',label='coordinate added with 0.1')
    # plt.plot(fpr_fusion2_patch,tpr_fusion2_patch,color='red',label='coordinate added with 0.2')
    # plt.plot(fpr_inten_eye_patch,tpr_inten_eye_patch,color='black',label='eye aligned intensity (with patches)')
    # plt.plot(fpr_inten_eye_NoPatch,tpr_inten_eye_NoPatch,color='coral',label='eye aligned intensity (without patches)')
    # #plt.xscale('log')
    # plt.legend()
    # plt.grid()
    # #plt.show()
    # plt.savefig(path_save_results+'ROC_in_fold'+str(test_fold_index)+'.png')

### Calculate average AUC:
average_AUC_inten_patch = np.asarray(AUC_inten_patch).mean()
average_AUC_fusion1_patch = np.asarray(AUC_fusion1_patch).mean()
average_AUC_fusion2_patch = np.asarray(AUC_fusion2_patch).mean()
average_AUC_inten_eye_patch = np.asarray(AUC_inten_eye_patch).mean()
average_AUC_inten_eye_NoPatch = np.asarray(AUC_inten_eye_NoPatch).mean()
save_variable(variable=average_AUC_inten_patch, name_of_variable='average_AUC_inten_patch', path_to_save=path_save_results)
save_variable(variable=average_AUC_fusion1_patch, name_of_variable='average_AUC_fusion1_patch', path_to_save=path_save_results)
save_variable(variable=average_AUC_fusion2_patch, name_of_variable='average_AUC_fusion2_patch', path_to_save=path_save_results)
save_variable(variable=average_AUC_inten_eye_patch, name_of_variable='average_AUC_inten_eye_patch', path_to_save=path_save_results)
save_variable(variable=average_AUC_inten_eye_NoPatch, name_of_variable='average_AUC_inten_eye_NoPatch', path_to_save=path_save_results)
print('The average AUC of (warped intensity patch): ' + str(average_AUC_inten_patch))
print('The average AUC of (warped intensity+coordinate patch with weight 0.1): ' + str(average_AUC_fusion1_patch))
print('The average AUC of (warped intensity+coordinate patch with weight 0.2): ' + str(average_AUC_fusion2_patch))
print('The average AUC of (eye-aligned intensity patch): ' + str(average_AUC_inten_eye_patch))
print('The average AUC of (eye-aligned intensity No-patch): ' + str(average_AUC_inten_eye_NoPatch))
