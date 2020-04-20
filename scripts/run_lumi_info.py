# import ROOT in batch mode
import sys
import re
#oldargv = sys.argv[:]
#sys.argv = [ '-b-' ]
#sys.argv = oldargv
import ROOT
from ROOT import TF1, TF2, TH1, TH2, TH2F, TProfile, TAxis, TMath, TEllipse, TStyle, TFile, TColor, TSpectrum, TCanvas, TPad, TVirtualFitter, gStyle
ROOT.gROOT.SetBatch(True)

print 'Number of arguments:', len(sys.argv), 'arguments.'
print 'Argument List:', str(sys.argv)
print sys.argv[0],sys.argv[1],sys.argv[2]
#from ctypes import c_uint8

# load FWLite C++ libraries
ROOT.gSystem.Load("libFWCoreFWLite.so")
ROOT.gSystem.Load("libDataFormatsFWLite.so")
ROOT.FWLiteEnabler.enable()

#
ROOT.gROOT.SetStyle('Plain') # white background
H_NEvents = ROOT.TH2F ("NEvents","NEvents",201,-2.5,1002.5, 201,-2.5,1002.5)
H_NEvents_Pass = ROOT.TH2F ("NEvents_Pass","NEvents_Pass",201,-2.5,1002.5, 201,-2.5,1002.5)

# load FWlite python libraries
from DataFormats.FWLite import Handle, Lumis, Events

genFilter, genFilterLabel = Handle("<GenFilterInfo>"), "genFilterEfficiencyProducer"
generator, generatorLabel = Handle("<GenLumiInfoHeader>"), "generator"

# open file (you can use 'edmFileUtil -d /store/whatever.root' to get the physical file name)

input_file_list  = sys.argv[1]+'_'+sys.argv[2]+'_list.txt'
print input_file_list
text_file = open(input_file_list, "r")
list = [line.rstrip() for line in text_file.readlines()]
print list

output_ROOT_file_name  = sys.argv[1]+'_'+sys.argv[2]+'_nevents.root'
output_file            = ROOT.TFile(output_ROOT_file_name, 'recreate')

for i in range(len(list)):

    #if i>3: break
    print list[i]
    lumiblocks = Lumis(list[i])
    
    for ilumi,lumiblock in enumerate(lumiblocks):
        #if ilumi>20: break
        lumiblock.getByLabel(genFilterLabel, genFilter)
        lumiblock.getByLabel(generatorLabel, generator)

        genFilterInfo = genFilter.product()
        generatorInfo = generator.product()
        items = re.split('_+', generatorInfo.configDescription())
        mMother=items[len(items)-2]
        mDaughter=items[len(items)-1]
        print generatorInfo.configDescription(),genFilterInfo.sumPassWeights(),genFilterInfo.sumWeights()
        print items,len(items),mMother,mDaughter
    
        H_NEvents.Fill(float(mMother),float(mDaughter),genFilterInfo.sumWeights());
        H_NEvents_Pass.Fill(float(mMother),float(mDaughter),genFilterInfo.sumPassWeights());

        del items
        del mMother,mDaughter
        del genFilterInfo
        del generatorInfo
        del lumiblock

    del lumiblocks
        
# Set up canvas : 
w =  700 
h =  700
can  = ROOT.TCanvas("can", "histograms   ", w, h)

H_NEvents.Draw("colz")
can.SaveAs("test.pdf")

output_file.cd()
H_NEvents.Write()
H_NEvents_Pass.Write()
