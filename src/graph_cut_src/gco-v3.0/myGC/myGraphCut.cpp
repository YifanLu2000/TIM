#include <mex.h>
#include <stdio.h>
#include <map>
#include <string>
#include "../GCoptimization.h"
#include <vector>
#include <math.h>
using namespace std;



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	#define GRAPH_EDGE  prhs[0]
	#define GRAPH_WEIGHT  prhs[1]
	#define NODE_COST  prhs[2]
	#define NODE_NUM  prhs[3]
	#define LABEL_NUM  prhs[4]
	#define LAMBDA  prhs[5]
    #define LABEL plhs[0]

	int edge_num = mxGetM(GRAPH_EDGE);
	int node_num = mxGetScalar(NODE_NUM);
	double lambda = mxGetScalar(LAMBDA);
	double* data_cost;
	data_cost = mxGetPr(NODE_COST);
	double* graph_edge;
	graph_edge = mxGetPr(GRAPH_EDGE);
	double* graph_weight;
	graph_weight = mxGetPr(GRAPH_WEIGHT);
	LABEL = mxCreateDoubleMatrix(node_num, 1, mxREAL);
	double *label_out = mxGetPr(LABEL);
	const int &point_number = node_num;
	size_t neighbor_number_ = (size_t) edge_num;
	Energy<double, double, double> *problem_graph =
			new Energy<double, double, double>(point_number, // The number of vertices
				neighbor_number_, // The number of edges
				NULL);
	// printf("Successful Create Graph\n");
	// Add a vertex for each point
	for (size_t i = 0; i < node_num; i++)
		problem_graph->add_node();
	// printf("Successful Init Graph\n");
	for (size_t i = 0; i < node_num; i++)
	{
		problem_graph->add_term1(i, (1-lambda)*data_cost[i], (1-lambda)*data_cost[node_num+i]);
		// printf("%d-->%f,%f\n",i,data_cost[i],data_cost[node_num+i]);
	}
	// printf("Successful Add term1\n");
	double energy1, energy2, energy_sum;
	double e00, e11, e01, e10 = 0; // Unused: e01 = 1.0, e10 = 1.0,
	// std::vector<std::vector<int>> used_edges(node_num, std::vector<int>(node_num, 0));
	for (size_t i = 0; i < edge_num; i++)
	{
		int point_u = (int) graph_edge[i]-1;
		int point_v = (int) graph_edge[edge_num+i]-1;
		// printf("%d-%d\n",point_u,point_v);
		// if (used_edges[point_u][point_v] == 1 ||
		// 				used_edges[point_v][point_u] == 1)
		// 				continue;

		// used_edges[point_u][point_v] = 1;
		// used_edges[point_v][point_u] = 1;
		e00 = graph_weight[i]*((data_cost[point_u]+data_cost[point_v])/2);
		// e11 = graph_weight[i]*(data_cost[node_num+point_u]+data_cost[node_num+point_v])/2;
		e11 = 0;
		e10 = graph_weight[i];
		e01 = graph_weight[i];
		// e10 = 1;
		// e01 = 1;
		// e11 = (data_cost[node_num+point_u]+data_cost[node_num+point_v])/2;
		if (e00+e11>2*graph_weight[i])
			printf("%d: %f--%f\n",i,e00+e11,2*graph_weight[i]);
		problem_graph->add_term2(point_u, // The current point's index
						point_v, // The current neighbor's index
						lambda*e00,
						lambda*e01, // = e01 * lambda
						lambda*e10, // = e10 * lambda
						lambda*e11);
		// printf("%d,%d-->%f\n",point_u,point_v,graph_weight[i]);
	}
	// printf("Successful Add term2\n");
	// Run the standard st-graph-cut algorithm
	problem_graph->minimize();
	// printf("Successful minimize\n");
	for (size_t i = 0; i < node_num; i++)
	{
		label_out[i] = problem_graph->what_segment(i);
		// printf("%d --> %d\n",i,problem_graph->what_segment(i));
	}
	delete problem_graph;
	// printf("Here we go\n");
	return;
	
}