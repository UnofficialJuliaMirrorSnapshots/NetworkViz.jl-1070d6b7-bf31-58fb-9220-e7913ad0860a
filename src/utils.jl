import NetworkViz
using LightGraphs
using ThreeJS
using Colors

export layout_spring, find_edges, drawWheel, drawGraph, drawGraphwithText, addEdge, removeEdge, addNode, removeNode, layout_spring, plot

function find_edges{T}(loc_x::Array{Float64,1},loc_y::Array{Float64,1},loc_z::Array{Float64,1},adj_matrix::Array{T,2})

    size(adj_matrix, 1) != size(adj_matrix, 2) && error("Adj. matrix must be square.")
    vertices = Tuple{Float64, Float64, Float64}[]
    const N = length(loc_x)
    for i = 1:N
        for j = 1:N
            i == j && continue
            if adj_matrix[i,j] != zero(eltype(adj_matrix))
                push!(vertices, (loc_x[i],loc_y[i],loc_z[i]), (loc_x[j],loc_y[j],loc_z[j]))
            end
        end
    end
    return vertices
end

function find_edges{T}(loc_x::Array{Float64,1},loc_y::Array{Float64,1},adj_matrix::Array{T,2})

    size(adj_matrix, 1) != size(adj_matrix, 2) && error("Adj. matrix must be square.")
    vertices = Tuple{Float64, Float64, Float64}[]
    const N = length(loc_x)
    for i = 1:N
        for j = 1:N
            i == j && continue
            if adj_matrix[i,j] != zero(eltype(adj_matrix))
                push!(vertices, (loc_x[i],loc_y[i],0), (loc_x[j],loc_y[j],0))
            end
        end
    end
    return vertices
end

function drawWheel(num::Int,t=1)
    g = WheelGraph(num)
    drawGraph(g,z=t)
end

function drawGraph(g::Union{LightGraphs.DiGraph,LightGraphs.Graph};
                               node=NodeProperty(Color[parse(Colorant,"#00004d") for i in 1:nv(g)],0.5,1),
                               edge=EdgeProperty("#ff3333",2),
                               z=1
                              )
    am = full(adjacency_matrix(g))
    loc_x, loc_y, loc_z = layout_spring(am,z)
    pts = zip(loc_x,loc_y,loc_z,node.color)
    if z == 1
        vertices = find_edges(loc_x, loc_y, loc_z, am)
    else
        vertices = find_edges(loc_x, loc_y, am)
    end
    plot(collect(pts),vertices, node, edge)
end

function drawGraph(am::Array{Int,2};
                            node=NodeProperty(Color[parse(Colorant,"#00004d") for i in 1:size(am,1)],0.5,1),
                            edge=EdgeProperty("#ff3333",2),
                            z=1
                           )
    loc_x, loc_y, loc_z = layout_spring(am,z)
    pts = zip(loc_x,loc_y,loc_z,node.color)
    if z == 1
        vertices = find_edges(loc_x, loc_y, loc_z, am)
    else
        vertices = find_edges(loc_x, loc_y, am)
    end
    plot(collect(pts),vertices, node, edge)
end

function addEdge(g::Graph, node1::Int, node2::Int, t=1)
    add_edge!(g,node1,node2)
    drawGraph(g,z=t)
end

function removeEdge(g::Graph, node1::Int, node2::Int, t=1)
    rem_edge!(g,node1,node2)
    drawGraph(g,z=t)
end

function addNode(g::Graph, t=1)
    add_vertex!(g)
    drawGraph(g,z=t)
end

function removeNode(g::Graph, node::Int, t=1)
    rem_vertex!(g,node)
    drawGraph(g,z=t)
end

function drawnode{T}(pts::Array{T,1},node::NodeProperty)
  if node.shape == 1
      ThreeJS.pointcloud(collect(pts)) <<
      [
        ThreeJS.pointmaterial(Dict(
        :color=>"white",
        :size=>node.size,
        :colorkind=>"vertex",
        :transparent=>true,
        :alphatest=>0.5,
        :texture=>"/pkg/NetworkViz/disc.png",
        ))
      ]
  else
      ThreeJS.pointcloud(collect(pts)) <<
      [
        ThreeJS.pointmaterial(Dict(
        :color=>"white",
        :size=>node.size,
        :colorkind=>"vertex",
        :transparent=>true,
        :alphatest=>0.5,
        ))
      ]
  end
end

function plot{T}(pts::Array{T,1}, vertices::Array{Tuple{Float64,Float64,Float64},1}, node::NodeProperty, edge::EdgeProperty)
  outerdiv() <<
  (
  initscene() <<
  [
      drawnode(pts,node),
      ThreeJS.line(vertices,kind="pieces") <<
      [
          ThreeJS.linematerial(Dict(
          :kind=>"basic",
          :color=>"$(edge.color)",
          :linewidth=>"$(edge.width)"
          ))
      ],
      pointlight(3.0, 3.0, 3.0),
      camera(0.0, 0.0, 5.0)
  ]
  )
end

function drawGraphwithText(g::Union{LightGraphs.DiGraph,LightGraphs.Graph},z=1)
    am = full(adjacency_matrix(g))
    loc_x, loc_y, loc_z = layout_spring(am,z)
    pts = zip(loc_x,loc_y,loc_z)
    if z == 1
        vertices = find_edges(loc_x, loc_y, loc_z, am)
    else
        vertices = find_edges(loc_x, loc_y, am)
    end
    outerdiv() <<
    (
    initscene() <<
    [
        ThreeJS.pointcloud(collect(pts)) <<
        [
          ThreeJS.pointmaterial(Dict(
          :color=>"#00004d",
          :size=>0.5,
          :transparent=>true,
          :alphatest=>0.2,
          :texture=>"/pkg/NetworkViz/disc.png",
          ))
        ],
        ThreeJS.line(vertices,kind="pieces") <<
        [
            ThreeJS.linematerial(Dict(
            :kind=>"basic",
            :color=>"#ff3333",
            :linewidth=>2
            ))
        ],
        [ThreeJS.text(map(x->x+0.08,item)...,"$idx") for (idx,item) in enumerate(pts)],
        pointlight(3.0, 3.0, 3.0),
        camera(0.0, 0.0, 5.0)
    ]
    )
end
